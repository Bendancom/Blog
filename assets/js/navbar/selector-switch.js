export function selectorSwitch(type) {
	document.getElementById("selector-switch").getElementsByClassName("current")[0].classList.remove("current")
	document.getElementById("selector-switch-menu").getElementsByClassName("current")[0].classList.remove("current")

	document.getElementById("selector-switch").getElementsByClassName(type)[0].classList.add("current")
	document.getElementById("selector-switch-menu").getElementsByClassName(type)[0].classList.add("current")

	localStorage.setItem("Selector",type);

	const single = [ ...document.getElementsByClassName("post-card-wrapper single"), ...document.getElementsByClassName("archive-item-wrapper single")]
	const series = [ ...document.getElementsByClassName("post-card-wrapper series"), ...document.getElementsByClassName("archive-item-wrapper series")]

	switch (type) {
		case "single":
			for (var i = 0; i < single.length; i++) {
				single[i].style.display = "block";
			}
			for (var i =0; i < series.length; i++) {
				series[i].style.display = "none";
			}
			break;
		case "series":
			for (var i =0; i < single.length; i++) {
				single[i].style.display = "none";
			}
			for (var i =0; i < series.length; i++) {
				series[i].style.display = "block";
			}
			break;
		case "all":
			for (var i =0; i < single.length; i++) {
				single[i].style.display = "block";
			}
			for (var i =0; i < series.length; i++) {
				series[i].style.display = "block";
			}
			break;
	}
}

function selectorNext() {
	const next = document.getElementById("selector-switch").getElementsByClassName("current")[0].nextElementSibling;

	if (next != null) {
		selectorSwitch(next.classList[0]);
	}
	else {
		selectorSwitch(document.getElementById("selector-switch").children[0].classList[0]);
	}
}

const nextButton = document.getElementById("selector-switch")
nextButton.addEventListener("click", selectorNext)
const buttons = document.getElementById("selector-switch-menu").getElementsByTagName("button")

for (var i = 0; i < buttons.length; i++) {
	buttons[i].addEventListener("click", (e) => {
		selectorSwitch(e.target.classList[0])
	})
}
