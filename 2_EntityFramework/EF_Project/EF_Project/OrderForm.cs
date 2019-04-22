using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static EF_Project.Program;
using System.Data.Entity;

namespace EF_Project
{
    public partial class OrderForm : Form
    {
        ProdContext db = new ProdContext();

        Order order = new Order(); 
        public OrderForm()
        {
            InitializeComponent();
        }


        void Clear()
        {
            txtProduct.Text = txtComment.Text = txtQuantity.Text = "";
            btnDeleteSelected.Enabled = false;
        }

        private void OrderForm_Load(object sender, EventArgs e)
        {
            Clear();

            productGridView.AutoGenerateColumns = false;
            productGridView.DataSource = db.Products.ToList();
            orderGridView.DataSource = db.Orders.Where(x => x.ProductId == 1).ToList();
        }

        private void btnPlaceOrder_Click(object sender, EventArgs e)
        {      
                var queryForID = db.Products.FirstOrDefault(p => p.Name == txtProduct.Text.Trim());
                if (queryForID == null)
                {
                    MessageBox.Show("No such product exists!", "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                
                if (txtQuantity.Text.Trim() == "")
                {
                    MessageBox.Show("Please provide a quantity", "Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                //All good so add:
                order.ProductId = queryForID.ProductID;
                order.Quantity = Convert.ToInt32(txtQuantity.Text.Trim());
                order.Comment = txtComment.Text;
                order.Date = DateTime.Now;

                //Save into database:
                db.Orders.Add(order);
                db.SaveChanges();

                MessageBox.Show("Order successfully added!");
                Clear();
                this.orderGridView.DataSource = db.Orders.Where(x => x.ProductId == order.ProductId).ToList();
                this.orderGridView.Refresh();
        }

        private void productGridView_SelectionChanged(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(this.productGridView.CurrentRow.Cells[0].Value);
            this.orderGridView.DataSource = (from orders in db.Orders
                                             where orders.ProductId == id
                                             select orders).ToList();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Clear();
        }

        private void btnDeleteSelected_Click(object sender, EventArgs e)
        {
            if (orderGridView.Rows.Count == 0)
            {
              MessageBox.Show("No order selected");
              return;
            }

            int id = Convert.ToInt32(this.orderGridView.CurrentRow.Cells[0].Value);
            bool confirmation = Confirm();

            if (confirmation)
            {
                var entry = db.Orders.SingleOrDefault(item => item.OrderId == id);
                db.Orders.Remove(entry);
                db.SaveChanges();

                orderGridView.DataSource = db.Orders.Where(x => x.ProductId == entry.ProductId).ToList();
            }
            else
            {
                return;
            }
        }

        public static bool Confirm()
        {
            const string message = "Are you sure you want to delete this order?";
            const string caption = "Order deletion";
            var result = MessageBox.Show(message, caption,
                                         MessageBoxButtons.YesNo,
                                         MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
                return true;
            else
                return false;
        }

        private void orderGridView_SelectionChanged(object sender, EventArgs e)
        {
            btnDeleteSelected.Enabled = true;
        }
    }
}
