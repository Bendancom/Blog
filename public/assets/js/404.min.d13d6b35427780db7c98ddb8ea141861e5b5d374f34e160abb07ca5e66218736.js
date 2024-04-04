(() => {
  // <stdin>
  function throttle(fn, delay) {
    let valid = true;
    return function() {
      if (!valid)
        return;
      valid = false;
      setTimeout(() => {
        fn.apply(this, arguments);
        valid = true;
      }, delay);
    };
  }
  window.addEventListener("load", () => {
    let vw = window.innerWidth;
    let vh = window.innerHeight;
    let bg = document.querySelector(".bg");
    const throttleReSize = throttle(() => {
      vw = window.innerWidth;
      vh = window.innerHeight;
    }, 300);
    window.addEventListener("resize", throttleReSize);
    window.addEventListener("mousemove", ({ clientX, clientY }) => {
      let ratoX = Number(clientX / vw * 0.5 * 100);
      let ratoY = Number(clientY / vh * 0.5 * 100);
      bg.style.backgroundPosition = `${ratoX}% ${ratoY}%`;
    }, false);
  });
})();
