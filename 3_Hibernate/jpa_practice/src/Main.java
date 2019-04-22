import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;


public class Main {

    private static SessionFactory sessionFactory = null;

    public static void main(String[] args) {

        sessionFactory = getSessionFactory();
        Session session = sessionFactory.openSession();
        Transaction tx = session.beginTransaction();

        Category catCutlery = new Category("Cutlery", "Things you use to eat");
        Category catElectronics = new Category("Electronics", "All kinds of electronics");
        Category catFurniture = new Category("Furniture", "Things for your rooms");

        session.save(catCutlery);
        session.save(catElectronics);
        session.save(catFurniture);

        Address address1 = new Address("Cutlery City", "Cutlery Avenue", "212341");
        Address address2 = new Address("Silicon Valley", "Silicon Street", "413482");
        Address address3 = new Address("Furniturepolis", "Furniture Grove", "316741");

        Supplier supCutlery = new Supplier("BestCutleryInc.", address1);
        Supplier supElectronics = new Supplier("SuperElectronics", address2);
        Supplier supFurniture = new Supplier("FurnitureForYou.com", address3);

        session.save(supCutlery);
        session.save(supElectronics);
        session.save(supFurniture);

        /*Product product1 = new Product("Fork", 4, catCutlery, supCutlery);
        Product product2 = new Product("Spoon", 2, catCutlery, supCutlery);
        Product product3 = new Product("Knife", 8, catCutlery, supCutlery);

        Product product4 = new Product("Smartphone 2000", 9, catElectronics, supElectronics);
        Product product5 = new Product("Ultra Computer", 2, catElectronics, supElectronics);

        Product product6 = new Product("Table", 3, catFurniture, supFurniture);*/

        /*session.save(product1);
        session.save(product2);
        session.save(product3);
        session.save(product4);
        session.save(product5);
        session.save(product6);
*/
        Invoice invoice1 = new Invoice();
        Invoice invoice2 = new Invoice();

        session.save(invoice1);
        session.save(invoice2);

        tx.commit();
        session.close();
    }


    private static SessionFactory getSessionFactory() {
        if (sessionFactory == null) {
            Configuration configuration = new Configuration();
            sessionFactory = configuration.configure().buildSessionFactory();
        }
        return sessionFactory;
    }
}


//Zapytanie o produkt:
/*      System.out.println("Enter a product name and quantity:\n");
        Scanner inputScanner = new Scanner(System.in);
        String prodName = inputScanner.nextLine();

        String[] split = prodName.split(" ");
        Product product = new Product(split[0], Integer.valueOf(split[1]));*/

//Supplier sup = new Supplier("Spoons Inc.", "Spoon Avenue 13", "Spoonville");
//session.save(sup);
//Product foundProduct = session.get(Product.class, 1);
//foundProduct.setSupplier(sup);