using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Windows.Forms;

namespace EF_Project
{
    class Program
    {
        public class Order
        {
        public int  OrderId { get; set; }
        public int  ProductId { get; set; }
        [Required]
        public int  Quantity { get; set; }
        public DateTime Date { get; set; }
        public string Comment { get; set; }
        }

        public class Customer
        {
            [Key]
            public string CompanyName { get; set; }
            public string Description { get; set; }
        }

        public class Category
        {
            public int CategoryID { get; set; }
            public string Name { get; set; }
            public string Description { get; set; }
            public List<Product> Products { get; set; }
        }

        public class Product
        {
            public int ProductID { get; set; }
            public string Name { get; set; }
            public int UnitsInStock { get; set; }
            public int CategoryID { get; set; }
            [Column("UnitPrice", TypeName = "Money")]
            public decimal UnitPrice { get; set; }
        }

        public class ProdContext : DbContext
        {
            protected override void OnModelCreating(DbModelBuilder modelBuilder)
            {
                modelBuilder.Entity<Order>().Property(o => o.OrderId)
                .HasColumnName("OrderID");
            }

            public DbSet<Category> Categories { get; set; }
            public DbSet<Product> Products { get; set; }
            public DbSet<Customer> Customers { get; set; }
            public DbSet<Order> Orders { get; set; }
        }

        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Form categoryForm = new CategoryForm();
            Form orderForm = new OrderForm();

            using (var db = new ProdContext())
            {


                //Console.Write("Enter a name for a new Category:");
                //var name = Console.ReadLine();

                //var category = new Category { Name = name };
                // db.Categories.Add(category);
                //db.SaveChanges();


                // Display all Categories from the database
                //var query = from c in db.Categories
                //            orderby c.Name
                //            descending
                //            select c;


                //Method based lazy:
                // IEnumerable<Category> query2 = db.Categories.OrderByDescending(c => c.Name);

                //Method based eager:
                //IEnumerable<Category> query3 = db.Categories.OrderByDescending(c => c.Name).ToList();

                // Console.WriteLine("All categories in the database:");
                // foreach (var item in query2)
                // {
                //     Console.WriteLine("{0}", item.Name );
                // }

                //Console.WriteLine("All categories in the database:");
                //foreach (var item in query3)
                //{
                //    Console.WriteLine("{0}", item.Name);
                //}


                // Console.WriteLine("Press any key to exit...");
                //Console.ReadKey();




                //-----------------------------------------------------------------------------------------------
                //METODY, KAŻDA W DWOCH WERSJACH

                //Pobiorą i wyświetlą wszystkie kategorie i produkty wykorzystujac:

                //1. Join -----------------
                //Query
                var join_query = from c in db.Categories
                                 join p in db.Products on c.CategoryID equals p.CategoryID
                                 into products
                                 select new
                                 {
                                     CatName = c.Name,
                                     Products = products
                                 };
                //Method
                var method_join_query = db.Categories
                    .GroupJoin(db.Products,
                          c => c.CategoryID,
                          p => p.CategoryID,
                          (c, p) => new
                          {
                              CatID = c.CategoryID,
                              CatName = c.Name,
                              Products = db.Products.Where(x => x.CategoryID == c.CategoryID).ToList()
                          });


                //  Console.WriteLine("All categories and products in the database:");
                //  foreach (var item in method_join_query)
                //  {
                //     Console.WriteLine("{0}:", item.CatName);
                //      foreach (var prod in item.Products)
                //      {
                //          Console.WriteLine("{0}", prod.Name);
                //      }
                //     Console.WriteLine("\n");
                //  }
                //     Console.WriteLine("Press any key to exit...");
                //     Console.ReadKey();



                //Navigation Properties---------------------------------------
                var navigationQuery1 = from c in db.Categories
                                       select new
                                       {
                                           CatName = c.Name,
                                           Prods = c.Products
                                       };


                //Lazy vs Eager-----------------------------------------------
                //Lazy:
                //Query
                var join_query2 = (from c in db.Categories
                                       join p in db.Products on c.CategoryID equals p.CategoryID
                                       into products
                                       select new
                                       {
                                           CatName = c.Name,
                                           Products = products
                                       });

                    //method
                    var method_join_query2 = db.Categories
                        .GroupJoin(db.Products,
                              c => c.CategoryID,
                              p => p.CategoryID,
                              (c, p) => new
                              {
                                  CatName = c.Name,
                                  Products = db.Products.Where(x => x.CategoryID == c.CategoryID).ToList()                                  
                              });



                    //Eager:
                    //Query
                    var join_query3 = (from c in db.Categories.Include("Products")
                                       join p in db.Products on c.CategoryID equals p.CategoryID
                                       into products
                                       select new
                                       {
                                           CatName = c.Name,
                                           Products = products                                           
                                       }).ToList();

                    //method
                    var method_join_query3 = db.Categories.Include(c => c.Products)
                        .GroupJoin(db.Products,
                              c => c.CategoryID,
                              p => p.CategoryID,
                              (c, p) => new
                              {
                                  CatName = c.Name,
                                  Products = db.Products.Where(x => x.CategoryID == c.CategoryID).ToList()                                  
                              }).ToList();





                //2. Dla każdej kategorii pokaza ilość produktów---------------------------
                //a) Query
                var count_join_query = from c in db.Categories
                                           join p in db.Products on c.CategoryID equals p.CategoryID
                                           into res
                                           select new
                                           {
                                               CatName = c.Name,
                                               Count = res.Count()
                                           };


                    //b) Method
                    var count_method_join_query = db.Categories
                                .GroupJoin(db.Products,
                                      c => c.CategoryID,
                                      p => p.CategoryID,
                                      (c, p) => new
                                      {
                                          CatName = c.Name,
                                          Count = c.Products.Count()
                                      }).Distinct().OrderByDescending(x => x.Count);


                    Console.WriteLine("All categories in the database:");
                    foreach (var item in count_join_query)
                    {
                       Console.WriteLine("{0}\t{1}", item.CatName, item.Count);
                    }



                //categoryForm.ShowDialog();
                orderForm.ShowDialog();
                Console.WriteLine("Press any key to exit...");
                Console.ReadKey();

                //Console.WriteLine("Press any key to exit...");
                //Console.ReadKey();
            }
        }
        
    }
}
