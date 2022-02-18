
// const { displayAlert } = require('../script')

// require('!!file-loader?name=[name].[ext]!../index.html')
// // require('../css/tuto.webflow.css');

// const btn = <button onClick={ () => displayAlert() }>Click Me</button>
// ReactDOM.render(
//     btn,
//     document.getElementById('root')
// );



// var createReactClass = require('create-react-class')

// var Page = createReactClass({
//   render(){
//     return <JSXZ in="template" sel=".container">
//       <Z sel=".item">Burgers</Z>,
//       <Z sel=".price">50</Z>
//     </JSXZ>
//   }
// })

// ReactDOM.render(
//   <Page/>,
//   document.getElementById('burger')
// )

require('!!file-loader?name=[name].[ext]!../index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

/* required css for our application */
require('../css/tuto.webflow.css');


var Qs = require('qs')
var Cookie = require('cookie')


var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && {handlerPath: [Layout, Header, Orders]}; // Note that we use the "&&" expression to simulate a IF statement
    }
  }, 
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path);
      return r && {handlerPath: [Layout, Header, Order],  order_id: r[1]}; // Note that we use the "&&" expression to simulate a IF statement
    }
  }
}

var Child = createReactClass({
  render(){
    var [ChildHandler, ...rest] = this.props.handlerPath;
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var browserState = {Child: Child}


var Page = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".supcontainer">
    </JSXZ>
  }
})

ReactDOM.render(<Page/>, document.getElementById('root'));


var orders = [
  {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
  {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
  {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
  {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
]


var Table = createReactClass({
  render(){
    return orders.map(order => (<JSXZ in="orders" sel=".table-line">
    <Z sel=".command-number">{order.remoteid}</Z>
    <Z sel=".customer-name">{order.custom.customer.full_name}</Z>
    <Z sel=".adress1">{order.custom.billing_address}</Z>
    <Z sel=".quantity">{order.items}</Z>
    </JSXZ>
    ))
  }
})
  
ReactDOM.render(<Table/>, document.getElementById('table-lines'));


var Layout = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".layout">
        <Z sel=".layout-container">
          <this.props.Child {...this.props}/>
        </Z>
      </JSXZ>
  }
})

var Header = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".layout">
        <Z sel=".header-container">
          <this.props.Child {...this.props}/>
        </Z>
      </JSXZ>
  }
})

var Orders = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".layout">
        <Z sel=".orders-container">
        </Z>
      </JSXZ>
  }
})

var Order = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".layout">
        <Z sel=".order-container">
        </Z>
      </JSXZ>
  }
})

var ErrorPage = createReactClass({
  render(){
    return <JSXZ in="orders" sel=".layout">
        <Z sel=".errorPage-container">
        </Z>
      </JSXZ>
  }
})

function onPathChange() {
  var path = location.pathname;
  var qs = Qs.parse(location.search.slice(1));
  var cookies = Cookie.parse(document.cookie);

  var route;
  
  // We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs)
    if (routeProps){
        route = key
          break;
    }
  }

  // We add the route name and the route Props to the global browserState
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }

  // If the path in the URL doesn't match with any of our routes, we render an Error component (we will have to create it later)
  if(!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404}/>, document.getElementById('root'))

  // If we found a match, we render the Child component, which will render the handlerPath components recursively, remember ? ;)
  ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
}

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange() // We also call onPathChange once when the js is loaded