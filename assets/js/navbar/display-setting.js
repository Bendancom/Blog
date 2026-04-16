function switchDisplaySetting(){
	const setting = document.getElementById("display-setting");
	const Input = document.getElementById("hue-slider");
	const Show = document.getElementById("display-setting-hue");
	const hue = localStorage.getItem("Hue")

	if (hue != null) {
		Show.textContent = hue
		Input.value = hue;
	}

	if (setting.classList.contains("hidden")) {
		setting.style.display = "flex";
		setting.classList.remove("hidden");
	}
	else {
		setting.style.display = "none";
		setting.classList.add("hidden");
	}
}

function setHue() {
	const Input = document.getElementById("hue-slider");
	const Show = document.getElementById("display-setting-hue");
	localStorage.setItem("Hue",Input.value);
	Show.textContent = Input.value;
	document.documentElement.style.setProperty("--hue",Input.value);
}

(function() {
	const hue = localStorage.getItem("Hue")
	if (hue != null) {
		document.documentElement.style.setProperty("--hue",hue);
	}
})()
