import SwiftUI

struct OTPDigitBox: View {

    let digit: String

    let active: Bool

    var body: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 18
            )

            .fill(
                AppColors.cardBackground
            )

            .overlay(

                RoundedRectangle(
                    cornerRadius: 18
                )

                .stroke(

                    active

                    ? AppColors.primaryBlue

                    : AppColors.borderColor,

                    lineWidth: active ? 2 : 1

                )

            )

            .shadow(

                color:

                    active

                ? AppColors.primaryBlue.opacity(0.20)

                : .clear,

                radius: 10,

                y: 4

            )

            Text(digit)

                .font(

                    .system(

                        size: 30,

                        weight: .bold

                    )

                )

                .foregroundColor(

                    AppColors.primaryText

                )

        }

        .frame(

            width: 50,

            height: 65

        )

        .scaleEffect(

            active ? 1.05 : 1

        )

        .animation(

            .spring(

                response: 0.25,

                dampingFraction: 0.7

            ),

            value: active

        )

        .animation(

            .spring(

                response: 0.25,

                dampingFraction: 0.7

            ),

            value: digit

        )
    }
}

#Preview {

    HStack {

        OTPDigitBox(
            digit: "1",
            active: false
        )

        OTPDigitBox(
            digit: "2",
            active: true
        )

        OTPDigitBox(
            digit: "3",
            active: false
        )

    }
    .padding()
}
