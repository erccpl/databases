import javax.persistence.*;
@SuppressWarnings("FieldCanBeLocal")


@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;

    private String productName;
    private int unitsInStock;
    private double unitPrice;

    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;


    public Product(){
    }

    public Product(String name, int unitsInStock, double unitPrice, Category category, Supplier supplier){
        this.productName = name;
        this.unitsInStock = unitsInStock;
        this.unitPrice = unitPrice;
        this.category = category;
        this.supplier = supplier;
    }



    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String newName) {
        this.productName = newName;
    }

    public void setSupplier(Supplier supplier) {
        this.supplier = supplier;
        this.supplier.getSuppliedProducts().add(this);
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public int getUnitsInStock() {
        return unitsInStock;
    }

    public void setUnitsInStock(int unitsInStock) {
        this.unitsInStock = unitsInStock;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
}
