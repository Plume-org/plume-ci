const search = new URL(document.URL).search
const id = search.substring(1, search.length)
const title = document.getElementById("title")
title.innerText = `#${id}`;
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

const logs = document.getElementById("logs");
const ansi_up = new AnsiUp();
const template = document.createElement('template')
const ws = new WebSocket(`ws://pr-list.joinplu.me/logs/${id}`)
ws.onmessage = (e) => {
	var html = ansi_up.ansi_to_html(e.data);
	template.innerHTML = html.trim();
	for (var i = 0; i < template.content.childNodes.length; ++i) {
		const node = template.content.childNodes[i];
		logs.appendChild(node);
	}
	logs.appendChild(document.createElement('br'))
}
