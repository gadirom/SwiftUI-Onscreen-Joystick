import PlaygroundSupport
import SwiftUI

struct JoystickView: View {
    
    struct framePreferenceKey: PreferenceKey {
        static var defaultValue = CGRect()
        
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            value = nextValue()
        }
    }
    
    init(offset: Binding<CGSize>, isTapped: Binding<Bool>, maxRadius: CGFloat){
        
        self._offset = offset
        self._isTapped = isTapped
        self.maxRadius = maxRadius
        
    }
    
    let maxRadius : CGFloat
    
    @Binding var offset: CGSize
    @Binding var isTapped: Bool
    
    @State var gestureLocation = CGSize(width: 0, height: 0)
    @State var startLocation = CGSize(width: 0, height: 0)
    @State var joystickFrame = CGRect()
    
    var body: some View{
        ZStack{
            //Rectangle().frame(width: 500, height: 500)
            if isTapped{
                ZStack{ 
                    Circle()
                        .frame(width: maxRadius * 3, height: maxRadius * 3)
                        .opacity(0.5)
                        .offset(startLocation)
                    Circle().frame(width: maxRadius, height: maxRadius)
                .offset(gestureLocation)
                }
            }
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                   DragGesture(minimumDistance:0, coordinateSpace:.global)
                    .onChanged { gesture in
                        
                        if !isTapped { 
                            isTapped = true
                            
                            let startWidth = gesture.startLocation.x - joystickFrame.minX - joystickFrame.width/2
                            let startHeight = gesture.startLocation.y - joystickFrame.minY - joystickFrame.height/2
                            startLocation = CGSize(width: startWidth, height: startHeight)
                        }
                        
                        var x = gesture.translation.width 
                        var y = gesture.translation.height 
                        
                        var r = sqrt(pow(x, 2) + pow(y, 2))
                        
                        if r > maxRadius{
                            let q = maxRadius / r
                            x *= q
                            y *= q
                        }
                        
                        let gestLocX = gesture.startLocation.x + x - joystickFrame.minX - joystickFrame.width/2
                        let gestLocY = gesture.startLocation.y + y - joystickFrame.minY - joystickFrame.height/2
                        
                        offset = CGSize(width: x, height: y)
                        gestureLocation = CGSize(width: gestLocX, height: gestLocY)
                        
                    }
                    .onEnded { _ in
                        
                        offset = .zero
                        isTapped = false
                        
                    }
            )
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: framePreferenceKey.self, value: geo.frame(in:.global))
                    }.onPreferenceChange(framePreferenceKey.self){self.joystickFrame = $0}
                )
            }.clipShape(Rectangle())
        }
    }

//
//
//Use Example 
//
//

struct TestView: View {
    
    let radius : CGFloat = 50
    @State var offset = CGSize(width: 0, height: 0)
    @State var isTapped = false
    
    var body: some View{
        HStack{ 
            VStack{
                VStack{
                    Text("X: \(offset.width)")
                    Text("Y: \(offset.height)")
                    if isTapped{ Text("isTapped")} else { Text("notTapped")}
                }
                Rectangle()
                    .fill(Color.blue)
                    .overlay(
                        JoystickView(offset: $offset, isTapped: $isTapped, maxRadius: radius)
                            .frame(width: 300, height: 300)
                            .opacity(0.5)
                    , alignment: .bottomTrailing)
                
            }
        }
    }
}

PlaygroundPage.current.setLiveView(TestView())
