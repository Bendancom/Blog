import { subroot } from "../subroot.js";

function languageSwitch(type){
	document.getElementById("language-switch").getElementsByClassName("current")[0].classList.remove("current");
	document.getElementById("language-switch").getElementsByClassName(type)[0].classList.add("current")

	document.getElementById("language-switch-menu").getElementsByClassName("current")[0].classList.remove("current");
	document.getElementById("language-switch-menu").getElementsByClassName(type)[0].classList.add("current");

	localStorage.setItem("Language",type)

	const path = window.location.pathname;
	let replace = subroot;
	if (replace[0] == "/")
		replace.slice(1);
	if (replace.charAt(replace.length - 1) == "/")
		replace.slice(0,-1);

	if (replace.length > 0 & path.indexOf(replace) != -1) {
		window.location.href = window.location.origin + "/" + replace + "/" + type + path.slice(2 + type.length + replace.length);
	} else {
		window.location.href = window.location.origin + "/" + type + path.slice(1 + type.length);
	}
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
