var React = require("react")
var createReactClass = require('create-react-class')
var remoteProps = require('../props.js')


var Orders = createReactClass({
    statics: {
      remoteProps: [remoteProps.orders]
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
          this.props.orders.value.map(order => (
            <JSXZ in="orders" sel=".table-line">
              <Z sel=".command-number">{order.remoteid}</Z>
              <Z sel=".customer-name">{order.custom.customer.full_name}</Z>
              <Z sel=".adress1">{this.computeAddress(order.custom.billing_address)}</Z>
              <Z sel=".quantity">{this.computeQuantities(order.custom.items)}</Z>
              <Z sel=".text-block-3"><a href={"/order/" + order.id}></a></Z>
            </JSXZ>))
        }
        </Z>
      </JSXZ>
    }
})

module.exports = Orders