export default {
  data: {
    currentIndex: 1
  },
  onInit() {
    console.info('Index page onInit');
  },
  onSwiperChange(e) {
    this.currentIndex = e.index;
  }
};
