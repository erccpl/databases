namespace EF_Project.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class AddCommentToOrder : DbMigration
    {
        public override void Up()
        {
            AddColumn("dbo.Orders", "Comment", c => c.String());
        }
        
        public override void Down()
        {
            DropColumn("dbo.Orders", "Comment");
        }
    }
}
