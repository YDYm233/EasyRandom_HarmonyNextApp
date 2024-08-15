
@Component
struct Options {
  @State message: string = 'Hello World';
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    Column(){
      Text('火速开发中')
    }
  }
}
export default Options