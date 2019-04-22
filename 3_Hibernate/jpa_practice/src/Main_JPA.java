import com.sun.org.apache.xpath.internal.operations.Or;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import java.util.List;

public class Main_JPA {

    public static void main(String[] args) {
        EntityManagerFactory emf = Persistence.
                createEntityManagerFactory("myDatabaseConfig");
        EntityManager em = emf.createEntityManager();
        EntityTransaction etx = em.getTransaction();
        etx.begin();

        Category catCutlery = new Category("Cutlery", "Things you use to eat");
        Category catElectronics = new Category("Electronics", "All kinds of electronics");
        Category catFurniture = new Category("Furniture", "Things for your rooms");

        em.persist(catCutlery);
        em.persist(catElectronics);
        em.persist(catFurniture);

        Address address1 = new Address("Cutlery City", "Cutlery Avenue", "212341");
        Address address2 = new Address("Silicon Valley", "Silicon Street", "413482");
        Address address3 = new Address("Furniturepolis", "Furniture Grove", "316741");

        Address address4 = new Address("Big City", "Business Street", "316351");
        Address address5 = new Address("Firm Town", "Firm Avenue", "916121");
        Address address6 = new Address("StartupVille", "Money Drive", "128350");

        Customer cust1 = new Customer("BigCompanyINC", address4, 10);
        Customer cust2 = new Customer("ImportantFirm", address5, 5);
        Customer cust3 = new Customer("TechStartup", address6, 20);

        em.persist(cust1);
        em.persist(cust2);
        em.persist(cust3);

        Supplier supCutlery = new Supplier("BestCutleryInc.", address1);
        Supplier supElectronics = new Supplier("SuperElectronics", address2);
        Supplier supFurniture = new Supplier("FurnitureForYou.com", address3);

        em.persist(supCutlery);
        em.persist(supElectronics);
        em.persist(supFurniture);

        Product product1 = new Product("Fork", 4, 15.00, catCutlery, supCutlery);
        Product product2 = new Product("Spoon", 2, 12.00, catCutlery,supCutlery);
        Product product3 = new Product("Knife", 8, 17.00, catCutlery, supCutlery);

        Product product4 = new Product("Smartphone 2000", 9,2500.00, catElectronics, supElectronics);
        Product product5 = new Product("Ultra Computer", 2,3500.00, catElectronics, supElectronics);

        Product product6 = new Product("Table", 3, 150.00, catFurniture, supFurniture);

/*
        em.persist(product2);
        em.persist(product1);
        em.persist(product3);
        em.persist(product4);
        em.persist(product5);
        em.persist(product6);
*/

        Invoice invoice1 = new Invoice(cust1);
        Invoice invoice2 = new Invoice(cust2);

        em.persist(invoice1);
        em.persist(invoice2);


        //Orders
        ProductOrder order1 = new ProductOrder(product1, 2, invoice1);
        ProductOrder order2 = new ProductOrder(product3, 1, invoice1);
        ProductOrder order3 = new ProductOrder(product5, 3, invoice1);
        ProductOrder order4 = new ProductOrder(product2, 8, invoice2);
        ProductOrder order5 = new ProductOrder(product4, 7, invoice2);
        ProductOrder order6 = new ProductOrder(product6, 4, invoice2);

        invoice1.addOrder(order1);
        invoice1.addOrder(order2);
        invoice1.addOrder(order3);

        invoice2.addOrder(order4);
        invoice2.addOrder(order5);
        invoice2.addOrder(order6);


        System.out.println("\n");

        Object result = em.createNativeQuery(
                " select sum(PRODUCT.UNITPRICE*((100-CUSTOMER.DISCOUNT)*0.1)*PRODUCTORDER.QUANTITY) as Total\n" +
                " from PRODUCT\n" +
                "  join PRODUCTORDER on PRODUCT.ID = PRODUCTORDER.PRODUCT_ID\n" +
                "  join INVOICE on PRODUCTORDER.INVOICE_ID = INVOICE.ID\n" +
                "  join CUSTOMER on INVOICE.CUSTOMER_ID = CUSTOMER.ID\n" +
                "  where INVOICE.ID = :invoice_id")
                .setParameter("invoice_id", 10)
                .getSingleResult();
        System.out.println(String.format("Total value of selected invoice:"));
        System.out.println(result);




        etx.commit();
        em.close();
    }
}

