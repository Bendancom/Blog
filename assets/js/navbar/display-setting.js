const switchButton = document.getElementById("display-settings-switch");
switchButton.addEventListener("click", () => {
	const setting = document.getElementById("display-setting");
	const Input = document.getElementById("hue-slider");
	const Show = document.getElementById("display-setting-hue");
	const hue = localStorage.getItem("Hue")

	if (hue != null) {
		Show.textContent = hue
		Input.value = hue;
	}

	if (setting.classList.toggle("hidden")) {
		setting.style.display = "none";
	}
	else {
		setting.style.display = "flex";
	}
});

const input = document.getElementById("hue-slider");
input.addEventListener("volumechange", (e) => {
	const hue = e.target.value;
	const show = document.getElementById("display-setting-hue");
	localStorage.setItem("Hue", hue);
	show.textContent = hue;
	document.documentElement.style.setProperty("--hue",hue);
})
