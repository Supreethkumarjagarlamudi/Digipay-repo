module.exports = {
    auth: {
        validPhone: "9876543210",
        invalidPhones: ["123", "abcde12345", "99999", "0000000000"],
        validOTP: "123456",
        invalidOTP: "999999"
    },
    customer: {
        defaultName: "Supreeth Kumar",
        editName: "Supreeth Jagarlamudi",
        defaultBudgetLimit: 10000.0,
        invalidBudgetLimit: -100.0,
        sampleCategories: ["Food", "Transport", "Shopping", "Bills"],
        locations: {
            indiranagar: { lat: 12.9, lon: 77.5, name: "Indiranagar Area, Bengaluru" },
            gachibowli: { lat: 17.4, lon: 78.3, name: "Gachibowli Area, Hyderabad" },
            adyar: { lat: 13.0, lon: 80.0, name: "Adyar Area, Chennai" }
        }
    },
    merchant: {
        defaultBusinessName: "Supreme Bakery",
        defaultCategory: "Food",
        defaultGST: "27AAAAA1111A1Z1",
        defaultUPI: "upi://pay?pa=supreme@okaxis&pn=SupremeBakery&am=10.00",
        invalidUPI: "invalid_link_address"
    }
};
