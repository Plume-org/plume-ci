fetch('/up.json')
	.then(r => r.json())
	.then(json => {
		for (const id of json) {
			fetch(`https://api.github.com/repos/Plume-org/Plume/pulls/${id}`, { mode: 'cors' })
				.then(r => r.json())
				.catch(() => {
					return {
						title: ''
					}
				})
				.then(json => {
					const linkTest = document.createElement('a')
					linkTest.href = `https://pr-${id}.joinplu.me/`
					linkTest.innerText = `#${id}: ${json.title || ''}`
					const linkLogs = document.createElement('a')
					linkLogs.href = `/log_viewer?${id}`
					linkLogs.innerText = '(view logs)'
					const linkGitHub = document.createElement('a')
					linkGitHub.href = `https://github.com/Plume-org/Plume/pull/${id}`
					linkGitHub.innerText = 'View on Github'

					const pTest = document.createElement('p')
					pTest.classList.add('grow')
					pTest.appendChild(linkTest)
					pTest.append(" ⋅ ")
					pTest.appendChild(linkLogs)
					const pGitHub = document.createElement('p')
					pGitHub.appendChild(linkGitHub)

					const li = document.createElement('li')
					li.appendChild(pTest)
					li.appendChild(pGitHub)
					li.classList.add('flex')
					document.getElementById('list').appendChild(li)
				})
		}
	})

