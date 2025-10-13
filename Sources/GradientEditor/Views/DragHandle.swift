import SwiftUI

public struct DragHandle: View {

    let viewModel: DragHandleViewModel
    var isHorizontal: Bool = false

    public var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                switch viewModel.colorStopType {
                case .single(let color):
                    Rectangle()
                        .fill(Color(cgColor: color))
                case .dual(let colorA, let colorB):
                    Rectangle()
                        .fill(LinearGradient(stops: [
                            .init(color: Color(cgColor: colorA), location: 0.5),
                            .init(color: Color(cgColor: colorB), location: 0.5)
                        ], startPoint: .top, endPoint: .bottom))
                }
            }
            .mask(DragHandleShape())
            .cornerRadius(4.0)
            
            Text(String(format: "%0.3f", arguments: [viewModel.position]))
                .font(Font.subheadline.monospacedDigit())
                .padding([.leading, .trailing], 1)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.background)
                }
                .padding(.trailing, 4)
                
        }
        .frame(width: 80, height: 30)
        .rotationEffect(isHorizontal ? .degrees(-90) : .degrees(0), anchor: .center)
        .offset(x: isHorizontal ? -40 : 0, y: isHorizontal ? -55 : -15)
    }
}

#Preview {
    VStack {
        DragHandle(viewModel: DragHandleViewModel(colorStop: ColorStop(position: 0.0, type: .single(.orange))))
        DragHandle(viewModel: DragHandleViewModel(colorStop: ColorStop(position: 0.55, type: .dual(.orange, .blue))))
        DragHandle(viewModel: DragHandleViewModel(colorStop: ColorStop(position: 1.0, type: .single(.orange))))
    }
}
