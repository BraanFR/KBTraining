var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
var remoteProps = require('../props.js')

var HTTP = require("../utils.js")


var Orders = createReactClass({
    statics: {
      remoteProps: [remoteProps.orders]
    },

    getInitialState: function() {
      return {value: this.props.orders.value};
    },
    
    computeQuantities(items) {
      var total = 0;

       items.forEach(element => {
          total += element.quantity_to_fetch;
        });

      return total;
    },

    computeAddress(address) {
      var fullAddress = "";

      var first = false;
      address.street.forEach(element => {
        if(!first) {
          fullAddress += "\n";
        }
        else{
          first = false;
        }

        fullAddress += element;
      });

      fullAddress += "\n" + address.postcode + " " + address.city;

      return fullAddress;
    },

    onClickMode(id) {
      this.props.modal({
        type: 'delete',
        title: 'Order deletion',
        message: `Are you sure you want to delete this ?`,
        callback: (trigger) => {
          if (trigger){
            this.props.loader(new Promise((success, f) => {
              HTTP.delete("/database?id=" + id)
              .then((res) => {
                this.setState({value : res});
              })
              .then(() => {
                success();
              })
            }));
          }
        }
      });
    },

    render(){
      return <JSXZ in="orders" sel=".orders-container">
        <Z sel=".search-orders">
          <ChildrenZ/>
        </Z>

        <Z sel=".table-headers">
          <ChildrenZ/>
        </Z>

        <Z sel=".table-lines">
        {
          this.state.value.map(order => (
            <JSXZ in="orders" sel=".table-line" key={order.id}>
              <Z sel=".command-number">{order.remoteid}</Z>
              <Z sel=".customer-name">{order.custom.customer.full_name}</Z>
              <Z sel=".adress1">{this.computeAddress(order.custom.billing_address)}</Z>
              <Z sel=".quantity">{this.computeQuantities(order.custom.items)}</Z>
              <Z sel=".details"><a href={"/order/" + order.id}></a></Z>
              <Z sel=".delete" onClick={()=> this.onClickMode(order.id)}><a href="#"></a></Z>
            </JSXZ>))
        }
        </Z>
      </JSXZ>
    }
})

module.exports = Orders