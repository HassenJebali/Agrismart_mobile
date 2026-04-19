import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
public class HashTest {
    public static void main(String[] args) {
        System.out.println(new BCryptPasswordEncoder().encode("Test@1234"));
    }
}
