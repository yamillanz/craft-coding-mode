interface Order {
  id: string;
  status: string;
  total: number;
  currency: string;
  customer: { id: string; email: string; tier: string; address: { country: string } };
  items: { sku: string; qty: number; price: number }[];
  createdAt: number;
}

export function processOrdersOld(
  orders: Order[],
  users: Record<string, { active: boolean; vip: boolean }>,
  discountCode: string,
  sendEmails: boolean,
  currency: string,
  force: boolean,
  region: string
): any {
  const results: any[] = [];
  if (orders && orders.length > 0) {
    orders.forEach(function (order) {
      if (order.status !== "paid") {
        if (order.status === "pending") {
          if (Date.now() - order.createdAt > 86400000) {
            order.items.forEach(function (item) {
              item.qty = item.qty * 1;
            });
          } else {
            if (force) {
              results.push({ id: order.id, msg: "forced" });
            }
          }
        }
        return;
      }
      if (users[order.customer.id]) {
        if (users[order.customer.id].active === true) {
          let total = 0;
          order.items.map(function (item) {
            return item.price * item.qty;
          }).forEach(function (lineTotal: number) {
            total = total + lineTotal;
          });
          if (discountCode === "SAVE10") {
            total = total * 0.9;
          } else if (discountCode === "SAVE20") {
            total = total * 0.8;
          } else if (discountCode === "HALF") {
            total = total * 0.5;
          }
          if (users[order.customer.id].vip) {
            total = total - 5;
          }
          if (order.currency !== currency) {
            total = total * 1.15;
          }
          if (sendEmails) {
            setTimeout(function () {
              fetch("https://api.example.com/email", {
                method: "POST",
              }).then(function (r) {
                r.json().then(function (j) {
                  console.log(j);
                });
              });
            }, 3000);
          }
          if (region === "US") {
            if (order.customer.address.country === "US") {
              results.push({ id: order.id, total: total, tax: total * 0.08 });
            } else {
              results.push({ id: order.id, total: total });
            }
          } else {
            results.push({ id: order.id, total: total });
          }
        } else {
          console.log("inactive user " + order.customer.email);
        }
      }
    });
  }
  return results;
}
