function languageSwitch(type){
	document.getElementById("language-switch").getElementsByClassName("current")[0].classList.remove("current");

	document.getElementById("language-switch").getElementsByClassName(type)[0].classList.add("current")

	document.getElementById("language-switch-menu").getElementsByClassName("current")[0].classList.remove("current");
	document.getElementById("language-switch-menu").getElementsByClassName(type)[0].classList.add("current");

	localStorage.setItem("Language",type)

	window.location.href = window.location.protocol + "//" + window.location.host + "/" + type + window.location.pathname.slice(3);
}

const switchButton = document.getElementById("language-switch");
switchButton.addEventListener("click", () => {
	const next = document.getElementById("language-switch-menu").getElementsByClassName("current")[0].nextElementSibling;

	if (next != null) {
		languageSwitch(next.classList[0])
	}
	else {
		languageSwitch(document.getElementById("language-switch-menu").children[0].classList[0])
	}
})

const buttons = document.getElementById("language-switch-menu").getElementsByTagName("button");
for (var i = 0; i < buttons.length; i++) {
	buttons[i].addEventListener("click", (e) => {
		languageSwitch(e.target.classList[0])
	})
}
