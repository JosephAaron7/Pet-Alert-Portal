import SwiftUI
import StoreKit

@main
struct JobWorthApp: App {
    @StateObject private var purchases = PurchaseManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchases)
                .task { await purchases.refreshEntitlements() }
        }
    }
}

@MainActor final class PurchaseManager: ObservableObject {
    static let productID = "com.jobworth.pro.lifetime" // Set exact matching ID in App Store Connect.
    @Published private(set) var isPro = false
    @Published private(set) var product: Product?
    @Published var message: String?
    init() {
        Task { await loadProduct(); await observeTransactions() }
    }
    func loadProduct() async {
        do { product = try await Product.products(for: [Self.productID]).first }
        catch { message = "Purchases are temporarily unavailable." }
    }
    func refreshEntitlements() async {
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil { unlocked = true }
        }
        isPro = unlocked
    }
    func purchase() async {
        guard let product else { message = "Pro is not available yet."; return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    message = "Purchase verification failed."; return
                }
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled: break
            case .pending: message = "Purchase pending approval."
            @unknown default: message = "Purchase status unknown."
            }
        } catch { message = "Purchase could not be completed." }
    }
    func restore() async {
        do { try await AppStore.sync(); await refreshEntitlements() }
        catch { message = "Could not restore purchases." }
    }
    private func observeTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result { await transaction.finish() }
            await refreshEntitlements()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var payout = ""
    @State private var materials = ""
    @State private var hours = ""
    @State private var laborRate = "40"
    @State private var mileage = ""
    @State private var mileageRate = "0.70"
    @State private var helper = ""
    @State private var other = ""
    @State private var targetMargin = "35"
    @State private var showAdvanced = false

    private func amount(_ value: String) -> Double {
        Double(value.replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: "$", with: "")
                    .trimmingCharacters(in: .whitespaces)) ?? 0
    }
    private var costs: Double {
        amount(materials) + amount(hours) * amount(laborRate) +
        amount(mileage) * amount(mileageRate) + amount(helper) + amount(other)
    }
    private var revenue: Double { amount(payout) }
    private var profit: Double { revenue - costs }
    private var margin: Double { revenue > 0 ? profit / revenue * 100 : 0 }
    private var targetPrice: Double {
        let t = amount(targetMargin) / 100
        return t >= 0 && t < 0.95 ? costs / (1 - t) : .infinity
    }
    private var valid: Bool {
        let values = [payout, materials, hours, laborRate, mileage, mileageRate, helper, other, targetMargin]
        return revenue > 0 && values.allSatisfy {
            $0.isEmpty || (Double($0.replacingOccurrences(of: ",", with: "")
                                    .replacingOccurrences(of: "$", with: "")) ?? -1) >= 0
        } && amount(targetMargin) > 0 && amount(targetMargin) < 95
    }
    private func field(_ label: String, _ value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField("0", text: value).keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel(label)
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Know if the job actually pays.")
                        .font(.largeTitle.bold())
                    Text("Enter your job and costs. Get a clear decision.")
                        .foregroundStyle(.secondary)
                    field("Job payout ($)", $payout)
                    HStack { field("Materials ($)", $materials); field("Labor hours", $hours) }
                    HStack { field("Hourly labor cost ($)", $laborRate); field("Travel miles", $mileage) }
                    HStack { field("Mileage cost ($/mile)", $mileageRate); field("Helper ($)", $helper) }
                    field("Other costs ($)", $other)
                    if valid {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(margin >= amount(targetMargin) && profit > 0 ? "TAKE IT" : profit > 0 ? "REBID" : "PASS")
                                .font(.headline).foregroundStyle(margin >= amount(targetMargin) && profit > 0 ? .green : .orange)
                            Text(profit, format: .currency(code: "USD"))
                                .font(.system(size: 44, weight: .bold))
                            Text("Estimated net profit")
                            Text("Margin: \(margin, specifier: "%.1f")%")
                            Text("Total cost: \(costs, format: .currency(code: "USD"))")
                            if purchases.isPro {
                                Text("Target bid: \(targetPrice, format: .currency(code: "USD"))")
                                    .font(.headline)
                                Button("Round bid up to nearest $50") {
                                    payout = String(Int(ceil(targetPrice / 50) * 50))
                                }
                            } else {
                                Button("Unlock target bid and Pro tools") { showAdvanced = true }
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                    } else {
                        Text("Enter a valid payout and nonnegative costs to calculate.")
                            .foregroundStyle(.secondary)
                    }
                    Button("Pro and purchases") { showAdvanced = true }
                }.padding()
            }
            .navigationTitle("JobWorth")
            .sheet(isPresented: $showAdvanced) {
                NavigationStack {
                    VStack(spacing: 16) {
                        Text("JobWorth Pro").font(.title.bold())
                        Text("One lifetime unlock. No subscription.")
                        if purchases.isPro { Text("Pro unlocked").foregroundStyle(.green) }
                        else {
                            Button(purchases.product?.displayPrice.map { "Unlock Pro — \($0)" } ?? "Pro unavailable") {
                                Task { await purchases.purchase() }
                            }.disabled(purchases.product == nil)
                            Button("Restore Purchases") { Task { await purchases.restore() } }
                        }
                        if let message = purchases.message { Text(message).font(.caption) }
                        Spacer()
                    }.padding()
                        .toolbar { ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showAdvanced = false }
                        }}
                }
            }
        }
    }
}
