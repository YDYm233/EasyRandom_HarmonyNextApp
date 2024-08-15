

@Component
struct PrivacyPolicy {
  @State message: string = 'Hello World';
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    Column(){
      Text('发明人:闫东阳\n发明项目：nextApp')
    }
  }
}
export default PrivacyPolicy