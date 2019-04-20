fetch("/up.json").then(function(response) {
	return response.json().then(function(json) {
		for(i = 0; i < json.length; i++) {
			id = json[i];
			fetch("https://api.github.com/repos/Plume-org/Plume/pulls/"+id, {mode: 'cors'}).then(

function(response) {
	return response.json().then(function(json) {
		link_test = document.createElement("a");
		link_test.href = "https://pr-" + id + ".joinplu.me/";
		link_github = document.createElement("a");
		link_github.href = "https://github.com/Plume-org/Plume/pull/" + id;
		link_github.innerText = "(view on Github)";
		if(json.title === undefined) {
			link_test.innerText = "#" + id;
		} else {
			link_test.innerText = "#" + id + " " + json.title;
		}
		li = document.createElement("li");
		li.appendChild(link_test);
		li.append(" ⋅ ");
		li.appendChild(link_github);
		document.getElementById("list").appendChild(li);
	})
}

			).catch(
function() {
		link_test = document.createElement("a");
		link_test.href = "https://pr-" + id + ".joinplu.me/";
		link_github = document.createElement("a");
		link_github.href = "https://github.com/Plume-org/Plume/pull/" + id;
		link_github.innerText = "(view on Github)";
		link_test.innerText = "#" + id;
		li = document.createElement("li");
		li.appendChild(link_test);
		li.append(" ⋅ ");
		li.appendChild(link_github);
		document.getElementById("list").appendChild(li);
}
			)
		}
	})
});
