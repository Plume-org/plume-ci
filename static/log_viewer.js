const search = new URL(document.URL).search
const id = search.substring(1, search.length)
const title = document.getElementById("title")
title.innerText = `#${id}`
fetch(`https://api.github.com/repos/Plume-org/Plume/pulls/${id}`, { mode: 'cors' })
	.then(r => r.json())
	.catch(() => {
		return {
			title: ''
		}
	})
	.then(json => {
		title.innerText = `#${id}: ${json.title || ''}`
	});

const logs = document.getElementById("logs")
const ansi_up = new AnsiUp()
const template = document.createElement('template')
const ws = new WebSocket(`wss://pr-list.joinplu.me/logs/${id}`)
ws.onmessage = (e) => {
	const message = e.data
	const html = ansi_up.ansi_to_html(message)
	if(message.includes("=>")) {
		logs.innerHTML += `&nbsp;&nbsp;&nbsp;&nbsp;${html}<br/>`
	} else {
		logs.innerHTML += `${html}<br/>`
	}
}
