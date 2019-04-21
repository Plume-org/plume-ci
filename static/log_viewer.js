let search = new URL(document.URL).search;
let id = search.substring(1, search.length);
let title = document.getElementById("title");
title.innerText = `#${id}: `;
fetch(`https://api.github.com/repos/Plume-org/Plume/pulls/${id}`, { mode: 'cors' })
	.then(r => r.json())
	.catch(() => {
		return {
			title: ''
		}
	})
	.then(json => {
		title.innerText = `#${id}: ${json.title || ''}`;
	});

let logs = document.getElementById("logs");
var ansi_up = new AnsiUp;
const template = document.createElement('template')
ws = new WebSocket(`ws://pr-list.joinplu.me/logs/${id}`);
ws.onmessage = function (e) {
	console.log(e.data);
	var html = ansi_up.ansi_to_html(e.data);
	template.innerHTML = html.trim();
	for (var i = 0; i < template.content.childNodes.length; ++i) {
		let node = template.content.childNodes[i];
		logs.appendChild(node);
	}
	logs.appendChild(document.createElement('br'))
}
