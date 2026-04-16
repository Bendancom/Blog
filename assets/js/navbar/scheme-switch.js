function schemeSwitch(type) {
	const button = document.getElementById("scheme-switch")
	button.getElementsByClassName("current")[0].classList.remove("current");
	button.getElementsByClassName(type)[0].classList.add("current");
	
	const menu = document.getElementById("scheme-switch-menu")
	menu.getElementsByClassName("current")[0].classList.remove("current");
	menu.getElementsByClassName(type)[0].classList.add("current");

	applyScheme(type);
	localStorage.setItem("Scheme", type);
}

function applyScheme(type) {
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
}

function schemeNext() {
	const next = document.getElementById("scheme-switch").getElementsByClassName("current")[0].nextElementSibling;
	if (next != null) {
		schemeSwitch(next.classList[0])
	}
	else {
		schemeSwitch(document.getElementById("scheme-switch").children[0].classList[0])
	}
}

(function () {
	const scheme = localStorage.getItem("Scheme");
	if (scheme != null){
		applyScheme(scheme)
	}
	else {
		applyScheme("system")
		localStorage.setItem("Scheme","system")
	}
})();
