function applyParams() {
	const params = new URLSearchParams(window.location.search);

	const single = document.getElementsByClassName("archive-item-wrapper single");
	for (var i = 0; i < single.length; i++) {
		const category = single[i].getAttribute("data-category");
		const tags = single[i].getAttribute("data-tags").split(" ");

		if (category != "" && params.get("category") != null) {
			if (category != params.get("category")) {
				continue;
			}
		}
		if (tags.length > 0 && params.get("tag") != null) {
			if (tags.indexOf(params.get("tag")) == -1) {
				continue;
			}
		}
		single[i].children[0].style.display = "flex"
	}


	const series = document.getElementsByClassName("archive-item-wrapper series")
	for (var i = 0; i < series.length; i++) {
		const seriesLinks = series[i].getElementsByClassName("archive-series-link");
		var size = 0;
		for (var j = 0; j < seriesLinks.length; j++) {
			const category = seriesLinks[j].getAttribute("data-category");
			const tags = seriesLinks[j].getAttribute("data-tags").split(" ");

			if (category != "" && params.get("category") != null) {
				if (category != params.get("category")) {
					continue;
				}
			}
			if (tags.length > 0 && params.get("tag") != null) {
				if (tags.indexOf(params.get("tag")) == -1) {
					continue;
				}
			}
			seriesLinks[j].style.display = "flex";
			size++;
		}
		if (size == 0) {
			series[i].children[0].style.display = "none"
		}

		const latestLinks = series[i].getElementsByClassName("archive-latest-link");
		var link = null;
		for (var j = 0; j < latestLinks.length; j++) {
			const category = latestLinks[j].getAttribute("data-category");
			const tags = latestLinks[j].getAttribute("data-tags").split(" ");

			if (category != "" && params.get("category") != null) {
				if (category != params.get("category")) {
					continue;
				}
			}
			if (tags.length > 0 && params.get("tag") != null) {
				if (tags.indexOf(params.get("tag")) == -1) {
					continue;
				}
			}
			if (link == null) {
				link = latestLinks[j];
			}
			if (
				new Date(link.getAttribute("data-date")) <
				new Date(latestLinks[j].getAttribute("data-date"))
			) {
				link = latestLinks[j];
			}
		}
		if (link != null) {
			link.style.display = "flex";
		}

		const latestDates = series[i].getElementsByClassName("archive-latest-date");
		var date = null;
		for (var j = 0; j < latestDates.length; j++) {
			const category = latestDates[j].getAttribute("data-category");
			const tags = latestDates[j].getAttribute("data-tags").split(" ");

			if (category != "" && params.get("category") != null) {
				if (category != params.get("category")) {
					continue;
				}
			}
			if (tags.length > 0 && params.get("tag") != null) {
				if (tags.indexOf(params.get("tag")) == -1) {
					continue;
				}
			}

			if (date == null) {
				date = latestDates[j];
				continue;
			}
			if (
				new Date(date.getAttribute("data-date")) <
				new Date(latestDates[j].getAttribute("data-date"))
			) {
				date = latestDates[j];
			}
		}
		if (date != null) {
			date.style.display = "flex"
		}
	}
}
