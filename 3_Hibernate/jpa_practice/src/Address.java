import javax.persistence.Embeddable;
import javax.persistence.Entity;

@SuppressWarnings("FieldCanBeLocal")


@Embeddable
public class Address {

    private String city;
    private String street;
    private String zipCode;

    public Address(String city, String street, String zipCode){
        this.city = city;
        this.street = street;
        this.zipCode = zipCode;
    }

    public Address(){
    }
}

