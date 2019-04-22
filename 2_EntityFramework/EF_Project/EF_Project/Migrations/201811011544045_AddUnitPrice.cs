namespace EF_Project.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class AddUnitPrice : DbMigration
    {
        public override void Up()
        {
            DropForeignKey("dbo.Products", "Category_CategoryID", "dbo.Categories");
            DropIndex("dbo.Products", new[] { "Category_CategoryID" });
            RenameColumn(table: "dbo.Products", name: "Category_CategoryID", newName: "CategoryID");
            AddColumn("dbo.Products", "UnitPrice", c => c.Decimal(nullable: false, storeType: "money"));
            AlterColumn("dbo.Products", "CategoryID", c => c.Int(nullable: false));
            CreateIndex("dbo.Products", "CategoryID");
            AddForeignKey("dbo.Products", "CategoryID", "dbo.Categories", "CategoryID", cascadeDelete: true);
        }
        
        public override void Down()
        {
            DropForeignKey("dbo.Products", "CategoryID", "dbo.Categories");
            DropIndex("dbo.Products", new[] { "CategoryID" });
            AlterColumn("dbo.Products", "CategoryID", c => c.Int());
            DropColumn("dbo.Products", "UnitPrice");
            RenameColumn(table: "dbo.Products", name: "CategoryID", newName: "Category_CategoryID");
            CreateIndex("dbo.Products", "Category_CategoryID");
            AddForeignKey("dbo.Products", "Category_CategoryID", "dbo.Categories", "CategoryID");
        }
    }
}
