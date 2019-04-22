import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
@SuppressWarnings("FieldCanBeLocal")


@Entity
@DiscriminatorValue(value = "C")
public class Customer extends Company {

    @OneToMany(mappedBy = "customer")
    private Set<Invoice> invoices;

    private int discount;

    public Customer() {
        super();
        this.invoices = new HashSet<>();
    }

    public Customer(String companyName, Address address, int discount) {
        super(companyName, address);
        this.discount = discount;
        this.invoices = new HashSet<>();

    }

    public int getDiscount() {
        return discount;
    }

    public void setDiscount(int discount) {
        this.discount = discount;
    }

    public Set<Invoice> getInvoices() {
        return invoices;
    }

    public void setInvoices(Set<Invoice> invoices) {
        this.invoices = invoices;
    }
}