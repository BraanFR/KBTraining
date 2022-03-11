require('@kbrw/node_erlastic').server(function(term, from, current_val, done) {
    if (term == "hello") return done("reply", "Hello World !");
    else if (term == "what") return done("reply", "What what ?")
    else if (term == "kbrw") return done("reply", current_val)
    else if (term[0] == "kbrw") return done("noreply", current_val = term[1]);
    throw new Error("unexpected request")
});