import RollPageTest from './RollPage.test';
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  RollPageTest()
}