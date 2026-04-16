import Fuse from 'https://cdn.jsdelivr.net/npm/fuse.js@7.1.0/dist/fuse.mjs';

const post = document.getElementsByTagName("article")[0];
const segment = Segmentit.useDefault(new Segmentit.Segment());
function getArticleNode(article) {
    const findWalker = document.createTreeWalker(
        article,
        NodeFilter.SHOW_ELEMENT,
        {
            acceptNode: function(node) {
                if (node.textContent.trim().length == 0)
                    return NodeFilter.FILTER_REJECT;
                if (node.nodeName == 'CODE')
                    return NodeFilter.FILTER_REJECT;
                return NodeFilter.FILTER_ACCEPT;
            }
        }
    );
    
    const findNode = [];
    while (findWalker.nextNode()) {
        const textWalker = document.createTreeWalker(
            findWalker.currentNode,
            NodeFilter.SHOW_TEXT,
            {
                acceptNode: function(node) {
                    if (node.textContent.trim().length == 0)
                        return NodeFilter.FILTER_REJECT;
                    return NodeFilter.FILTER_ACCEPT;
                }
            }
        );
        
        const texts = [];
        let textNode;
        while (textNode = textWalker.nextNode()) {
            texts.push(textNode.textContent);
        }
        
        const currentNode = findWalker.currentNode;
        const nodeName = currentNode.nodeName.toUpperCase();

        const words = segment.doSegment(texts.join(''), { simple: true });

        findNode.push({
            text: words.join(' '),
			showText: texts.join(''),
            node: currentNode,
            elementType: nodeName
        });
    }
    return findNode;
}
const findNode = getArticleNode(post);

const fuseOptions = {
	keys: ["text"],
	includeScore: true,
	threshold: 0.3,
	distance: 100,
	ignoreDiacritics: true,
	ignoreLocation: true,
	minMatchCharLength: 1,
	findAllMatches: true,
};

const fuse = new Fuse(findNode,fuseOptions);

const input = document.getElementById("navbar-find-input");
const resultDiv = document.getElementById("navbar-find-result");
let blurTimer = null;

function jumpToNode(node) {
	resultDiv.style.display = "none";
    node.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
    });
}

function find(e) {
	const query = e.target.value.trim();
	resultDiv.innerHTML = '';

	if (!query) {
		resultDiv.style.display = "none";
		return;
	}
	const results = fuse.search(query);

	if (results.length == 0) {
		resultDiv.style.display = "none";
		return;
	}

	let max = results.length > 5 ? 5 : results.length;

	for (var i = 0; i < max; i++) {
		const result = results[i].item;
		const item = document.createElement("button");
		item.classList.add("navbar-find-result-item");

		const label = document.createElement("label");
		label.classList.add("navbar-find-result-label");
		label.appendChild(document.createTextNode(result.elementType));
		item.appendChild(label)

		item.appendChild(document.createTextNode(result.showText));

		item.addEventListener("click", jumpToNode.bind(null,result.node));
		resultDiv.appendChild(item);
	}
	resultDiv.style.display = "flex";
}

input.addEventListener('focus', find);
input.addEventListener('input', find);
input.addEventListener("blur", () => {
	setTimeout(() => {
		const active = document.activeElement;
		const buttons = document.getElementsByClassName("navbar-find-result-item")
		let isButton = false;
		for (var i = 0; i < buttons.length; i++) {
			if (active == buttons[i]) {
				isButton = true;
				break;
			}
		}
		if (!isButton) {
			resultDiv.style.display = "none"
		}
	},0)
});

const button = document.getElementById("navbar-find-button");
const findbar = document.getElementById("navbar-find-bar-wrapper");
button.addEventListener('click', () => {
	if (findbar.classList.contains("hidden")) {
		findbar.classList.remove("hidden");
		findbar.style.display = "flex";
	}
	else {
		findbar.classList.add("hidden");
		findbar.style.display = "none";
	}
});
