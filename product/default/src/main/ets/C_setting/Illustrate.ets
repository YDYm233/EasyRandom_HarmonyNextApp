
@Component
struct Agreement {
  @State message: string = 'Hello World';
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    Column(){
      Text('该版本目前为单机')
    }
  }
}
export default Agreement