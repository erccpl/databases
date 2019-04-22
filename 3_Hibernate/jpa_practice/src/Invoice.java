import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
public class Invoice {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;

    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, orphanRemoval=true, fetch = FetchType.EAGER)
    private Set<ProductOrder> orders;

    @ManyToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    public Invoice(){
        this.orders = new HashSet<>();
    }

    public Invoice(Customer customer){
        this();
        this.customer = customer;
    }




    public Set<ProductOrder> getOrders() {
        return orders;
    }

    public void addOrder(ProductOrder order) {
        this.orders.add(order);
    }

    public void removeOrder(ProductOrder order) {
        this.orders.remove(order);
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public int getId() {
        return this.getId();
    }
}

