import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
@SuppressWarnings("FieldCanBeLocal")

@Entity
@DiscriminatorValue(value = "S")
public class Supplier extends Company {

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL, orphanRemoval=true, fetch = FetchType.EAGER)
    private Set<Product> products;

    public Supplier(String companyName, Address address){
        super(companyName, address);
        this.products = new HashSet<>();
    }

    public Supplier() {
        super();
        this.products = new HashSet<>();
    }

    public void addToSuppliedProducts(Product product) {
        this.products.add(product);
        product.setSupplier(this);
    }

    public Set<Product> getSuppliedProducts() {
        return this.products;
    }

}
