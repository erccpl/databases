using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.Entity;
using static EF_Project.Program;

namespace EF_Project
{
    public partial class CategoryForm : Form
    {
        Category category = new Category();
        ProdContext db;
        public CategoryForm()
        {
            InitializeComponent();
        }

        void Clear()
        {
            txtName.Text = txtDescription.Text = "";
            btnEdit.Enabled = false;
            btnAdd.Enabled = true;
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            db = new ProdContext();
        
            db.Categories.Load();
            db.Products.Load();

            this.program_CategoryBindingSource.DataSource = db.Categories.Include(c => c.Products).ToList();
            this.productsBindingSource.DataSource = db.Products.ToList();

        }

        private void categoryDataGridView_SelectionChanged_1(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(this.categoryDataGridView.CurrentRow.Cells[0].Value);
            productsDataGridView.DataSource = (from p in db.Products
                                               where p.CategoryID == id
                                               select p).ToList();
        }


        private void program_CategoryBindingNavigatorSaveItem_Click(object sender, EventArgs e)
        {
            this.Validate();
            this.db.SaveChanges();
            this.categoryDataGridView.Refresh();
            this.productsDataGridView.Refresh();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Clear();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {

            if (txtName.Text.Trim() == "")
            {
                MessageBox.Show("Please provide a name for the category", "Error",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var checkQuery = (from categories in db.Categories
                              where categories.Name == txtName.Text.Trim()
                              select categories).ToList();

            if (checkQuery.Count != 0)
            {
                MessageBox.Show("This category already exists", "Error",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            category.Name = txtName.Text.Trim();
            category.Description = txtDescription.Text.Trim();


            db.Categories.Add(category);
            db.SaveChanges();

            MessageBox.Show("Category successfully added!");
            Clear();
            this.program_CategoryBindingSource.DataSource = db.Categories.ToList();
            this.categoryDataGridView.Refresh();
        }

        private void categoryDataGridView_DoubleClick(object sender, EventArgs e)
        {
            if(categoryDataGridView.CurrentRow.Index != -1)
            {
                category.CategoryID = Convert.ToInt32(categoryDataGridView.CurrentRow.Cells["CategoryID"].Value);
                category = db.Categories.Where(x => x.CategoryID == category.CategoryID).FirstOrDefault();
                txtName.Text = category.Name;
                txtDescription.Text = category.Description;

                btnAdd.Enabled = false;
                btnEdit.Enabled = true;
            }

        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            category.Name = txtName.Text.Trim();
            category.Description = txtDescription.Text.Trim();
            db.Entry(category).State = EntityState.Modified;
            db.SaveChanges();

            MessageBox.Show("Category successfully modified");
            this.categoryDataGridView.Refresh();
            Clear();
        }
    }
}
