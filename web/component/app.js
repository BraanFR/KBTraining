
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
var XMLHttpRequest = require("xhr2")

const routes = require("./routes.js")

const Layout = require("./classes/layout.js")
const Header = require("./classes/header.js")
const Orders = require("./classes/orders.js")
const Order = require("./classes/order.js")
const ErrorPage = require("./classes/error.js")
const Child = require("./classes/child.js")
const Page = require("./classes/page.js")
const Table = require("./classes/table.js")

const debug = false;

var HTTP = new (function(){
  this.get = (url)=> this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
      if(req.status >= 200 && req.status < 300){
      resolve(req.responseText && JSON.parse(req.responseText))
      }else{
      reject({http_code: req.status})
      }
    }
  req.onerror = (err)=>{
    if (debug) {
      console.log(req)
      console.log(err)
    }
    
    reject({http_code: req.status})
  }
  req.send(data && JSON.stringify(data))
  })
})()

var browserState = {Child: Child}

// ReactDOM.render(<Page/>, document.getElementById('root'));
  
// ReactDOM.render(<Table/>, document.getElementById('table-lines'));


function onPathChange() {
  if (debug){
    console.log("ON PATH CHANGE START")
  }

  var path = location.pathname;
  var qs = Qs.parse(location.search.slice(1));
  var cookies = Cookie.parse(document.cookie);

  var route;
  
  // We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs)
    if (routeProps){
      if (debug) {
        console.log("ROUTE MATCH");
        console.log(routeProps)
      }
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

  if(debug){
    console.log(browserState)
  }

  // If the path in the URL doesn't match with any of our routes, we render an Error component (we will have to create it later)
  if(!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404}/>, document.getElementById('root'))

  // If we found a match, we render the Child component, which will render the handlerPath components recursively, remember ? ;)
  // ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))

  addRemoteProps(browserState).then(
    (props) => {
      if(debug) {
        console.log("RENDER CHILD")
      }
      browserState = props
      // Log our new browserState
      console.log(browserState)
      // Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, (res) => {
      if(debug) {
        console.log("ERROR")
        console.log(res.http_code)
      }
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })

    if(debug) {
      console.log("ON PATH CHANGE END")
    }
}

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange() // We also call onPathChange once when the js is loaded


function addRemoteProps(props){
  return new Promise((resolve, reject)=>{
    // Here we could call `[].concat.apply` instead of `Array.prototype.concat.apply`.
    // ".apply" first parameter defines the `this` of the concat function called.
    // Ex: [0,1,2].concat([3,4],[5,6])-> [0,1,2,3,4,5,6]
    // Is the same as : Array.prototype.concat.apply([0,1,2],[[3,4],[5,6]])
    // Also : `var list = [1,2,3]` is the same as `var list = new Array(1,2,3)`
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c)=> c.remoteProps) // -> [[remoteProps.orders], null]
        .filter((p)=> p) // -> [[remoteProps.orders]]
    )

    if(debug) {
      console.log("RemoteProps")
      console.log(remoteProps)
    }
    
    remoteProps = remoteProps
      .map((spec_fun)=> spec_fun(props) ) // [{url: '/api/orders', prop: 'orders'}]
      .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if(remoteProps.length == 0){
      if(debug) {
        console.log('RESOLVED')
      }
      return resolve(props)
    }
    
    if(debug) {
      console.log("RemoteProps 2")
      console.log(remoteProps)
    }

    // All remoteProps can be queried in parallel. This is just the function definition, see its use below.
    const promise_mapper = (spec) => {
      if(debug) {
        console.log("PROMISE MAPPER")
        console.log(spec)
      }
      // we want to keep the url in the value resolved by the promise here : spec = {url: '/api/orders', value: ORDERS, prop: 'orders'}
      return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
    }

    const reducer = (acc, spec) => {
      if(debug) {
        console.log("REDUCER")
      }
      // spec = url: '/api/orders', value: ORDERS, prop: 'user'}
      acc[spec.prop] = {url: spec.url, value: spec.value}
      return acc
    }

    if(debug) {
      console.log("Before promise array")
    }

    const promise_array = remoteProps.map(promise_mapper)

    if(debug) {
      console.log("Promise array")
      console.log(promise_array)
    }

    return Promise.all(promise_array)
      .then(xs => xs.reduce(reducer, props), reject)
      .then((p) => {
        if(debug) {
          console.log("Promise then")
        }
      // recursively call remote props, because props computed from
      // previous queries can give the missing data/props necessary
      // to define another query
      return addRemoteProps(p).then(resolve, reject)
    }, reject)
  })
}

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}
// export and reuse in pages