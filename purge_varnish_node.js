var http = require('http'),
    sys = require('sys'),
    querystring = require('querystring');
    util = require('util');
    exec = require('child_process').exec;

// configura o servidor http
http.createServer(function(request, response) {
    sys.puts('Request for ' + request.url);

    switch (request.url) {
        case '/':
	    response.writeHead(200, { 'Content-Type' : 'text/html' });
	    response.write(
	        '<form action="/post_to_me" method="post">' +
		'Pool: <input type="text" name="nome_pool"><br />' +
		'String para PURGE: <input type="text" name="purge_string"><br />' +
		'<input type="submit" value="Submit">' +
		'</form>'
	    );
	    response.end();
	    break;
	case '/post_to_me':

	    response.writeHead(200, { 'Content-Type' : 'text/html' });

		post_handler(request, function(request_data) {
                response.write(
		  'String JSON:<br />' +
		  '<pre>' + sys.inspect(request_data) + '</pre>' +
		  '<hr>' +
		  'Valor individual:<br />' +
		  'Pool: <strong>' + request_data.nome_pool + '</strong><br />' +
		  'String para PURGE: <strong>' + request_data.purge_string + '</strong><br />'
                );
		
		// Define nomes dos pools e
		// verifica se o pool solicitado e' existente, se for, recebe o array de servidores
		if ( request_data.nome_pool = "pool_varnish" ) {
			var ps = ["varnish-1", "varnish-2", "varnish-3", "varnish-4"];
		}
		if ( request_data.nome_pool = "pool_parceiros_cache" ) {
			var ps =  ["parceiros-cache-1", "parceiros-cache-2", "parceiros-cache-3"];
		}
		if ( request_data.nome_pool = "pool_oi_cache" ) {
			var ps = ["oi-cache-1", "oi-cache-2", "oi-cache-3"];
		}

		for(var i in ps) {

		var command = 'curl -sL -w "%{http_code} %{time_total}\\n" "http://'+ps[i]+'?purge='+request_data.purge_string+'" -o /dev/null'

		console.log(ps[i]);
		console.log(command);

		child = exec(command, function(error, stdout, stderr){

		  	// todo: fazer imprimir em html e nao no console
			console.log('stdout: ' + stdout);
			console.log('stderr: ' + stderr);
			response.writeHead(200, { 'Content-Type' : 'text/html' });
			response.write('oi ' + stdout);
			

			if(error !== null){
				console.log('exec error: ' + error);
			}

		});
		}
		response.end();
	    });
	    break;
    };
}).listen(8000);

function post_handler(request, callback) {
    var _REQUEST = { };
    var _CONTENT = '';

    if (request.method == 'POST') {
        request.addListener('data', function(chunk) {
	    _CONTENT+= chunk;
	});

	request.addListener('end', function() {
            _REQUEST = querystring.parse(_CONTENT);
	    callback(_REQUEST);
	});
    };
};
