const button = document.getElementById("navbar-mobile-menu");
button.addEventListener("click", () => {
	const menu = document.getElementById("navbar-mobile-menu-wrapper");
	if (menu.classList.toggle("hidden")) {
		menu.style.display = "none";
	}
	else {
		menu.style.display = "block";
	}
})
