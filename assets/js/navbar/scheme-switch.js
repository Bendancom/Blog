function schemeSwitch(type) {
	const button = document.getElementById("scheme-switch")
	button.getElementsByClassName("current")[0].classList.remove("current");
	button.getElementsByClassName(type)[0].classList.add("current");
	
	const menu = document.getElementById("scheme-switch-menu")
	menu.getElementsByClassName("current")[0].classList.remove("current");
	menu.getElementsByClassName(type)[0].classList.add("current");

	switch(type) {
		case "light":
			document.documentElement.setAttribute("data-theme", "light");
			break;
		case "dark":
			document.documentElement.setAttribute("data-theme", "dark");
			break;
		case "system":
			document.documentElement.setAttribute("data-theme", "system");
			break;
	}

	const giscus = document.querySelector("iframe.giscus-frame");
	if (giscus != null) {
		giscus.contentWindow.postMessage(
			{
				giscus: {
					setConfig: {
						theme: type == "system" ? "preferred_color_scheme" : type
					}
				}
			},
			'https://giscus.app'
		)
	}
	localStorage.setItem("Scheme", type);
}

const switchButton = document.getElementById("scheme-switch");
switchButton.addEventListener("click", () => {
	const next = document.getElementById("scheme-switch").getElementsByClassName("current")[0].nextElementSibling;
	if (next != null) {
		schemeSwitch(next.classList[0])
	}
	else {
		schemeSwitch(document.getElementById("scheme-switch").children[0].classList[0])
	}
})

const buttons = document.getElementById("scheme-switch-menu").getElementsByTagName("button");
for (var i = 0; i < buttons.length; i++) {
	buttons[i].addEventListener("click", (e) => {
		schemeSwitch(e.target.classList[0])
	})
}
