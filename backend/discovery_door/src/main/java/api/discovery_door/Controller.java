package api.discovery_door;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import api.discovery_door.Database.CategoryDAO;
import api.discovery_door.Database.HistoryDAO;
import api.discovery_door.Database.MuseuDAO;
import api.discovery_door.Database.ReviewDAO;
import api.discovery_door.Database.UtilizadorDAO;

@RestController
public class Controller {

    /**
     * Frontend uses this method to check network status.
     *
     */
    @GetMapping("/checkNet")
    public boolean checkNet() {
        return true;
    }

    /**
     * Login user - check credentials.
     *
     * @param username Username of the user.
     * @param passwd   Password of the user.
     * @return Returns boolean - true if the login was successfull, false otherwise.
     */
    @GetMapping("/loginUser")
    public boolean loginUser(@RequestParam(value = "uName") String username,
            @RequestParam(value = "pw") String passwd) {
        return UtilizadorDAO.loginUser(username, passwd);
    }

    /**
     * Gives information about the current museums close to the user.
     *
     * @return List of museums in the given radius of the user or null, in case the
     *         list is empty.
     */
    @GetMapping("/allMuseums")
    public List<Museum> loadSurroundingMuseums() {
        // Check radius value - must be within bounds

        return makeMuseums(MuseuDAO.getMuseums());
    }

    /**
     * Check if the username is unique.
     *
     * @param username Username proposed by the user.
     * @return true if the username is available, false otherwise.
     */
    @GetMapping("/validateUsername")
    public boolean validateUsername(@RequestParam(value = "uName") String username) {
        return !UtilizadorDAO.existusername(username);
    }

    /**
     * Register user - unique username.
     *
     * @param username Username, already verified before calling "/register".
     * @param passwd   Password of the user.
     * @return true if the registration was successfull, false otherwise (maybe
     *         username is no longer available).
     */
    @GetMapping("/register")
    public boolean register(@RequestParam(value = "uName") String username,
            @RequestParam(value = "pw") String passwd) {
        return UtilizadorDAO.registerUser(username, passwd);
    }

    /**
     * Search museum name and returns the museum info.
     *
     * @param museumName Name (or part of name) of a presumable museum.
     * @return Museum instance with all the info, or null if museum not found.
     */
    @GetMapping("/getMuseumByName")
    public Museum getMuseumByName(@RequestParam(value = "mName") String museumName) {
        return new Museum(MuseuDAO.getMuseuByName(museumName), MuseuDAO.getImages(museumName), makeReviews(museumName),
                CategoryDAO.getCategoria(museumName));
    }

    /**
     * Get list of museums that respect the given constraints.
     *
     * @param radius Maximum distance from user.
     * @param price  Maximum price of the museum.
     * @param score  Minimum score of the museum.
     * @param theme  Theme of the museum (art, history, science, ...).
     * @return List of the museums that respect the constraints, or null, if list is
     *         empty.
     */
    @GetMapping("/getMuseumByFilters")
    public List<Museum> getMuseumByFilters(@RequestParam(value = "radius") Double radius,
            @RequestParam(value = "lat") Double latitude,
            @RequestParam(value = "lon") Double longitude,
            @RequestParam(value = "price") int price,
            @RequestParam(value = "score") int score,
            @RequestParam(value = "theme") String theme) {
        return makeMuseums(MuseuDAO.getMuseumsByFilters(radius, latitude, longitude, price, score, theme));
    }

    /**
     * After visiting a museum, add it to the visited/historic of visited museums
     * with some informations.
     *
     * @param username     Name of the user.
     * @param museumName   Name of the museum visited.
     * @param timeOfTravel Time that took to get to the museum (?).
     * @return True if the museum was added to the history of this user, false
     *         otherwise.
     */
    @GetMapping("/addToHistory")
    public boolean addToHistory(@RequestParam(value = "uName") String username,
            @RequestParam(value = "mName") String museumName,
            @RequestParam(value = "tot") int timeOfTravel) {
        return HistoryDAO.addToHistory(username, museumName, LocalDateTime.now().toString(), timeOfTravel);
    }

    /**
     * Rate the system.
     *
     * @param username Name of the user.
     * @param score    Score given by the user.
     * @return True if everything alright, false otherwise.
     */
    @GetMapping("/rateSystem")
    public boolean rateSystem(@RequestParam(value = "uName") String username,
            @RequestParam(value = "score") int score)

    {
        return UtilizadorDAO.addSystemRating(username, score);
    }

    /**
     * Review the museum: score and comment.
     *
     * @param username   Name of the user.
     * @param museumName Name of the museum.
     * @param score      Score given by the user to the museum.
     * @param comment    Score given by the user to the museum.
     * @return True if everything alright, false otherwise.
     */
    @GetMapping("/review")
    public boolean createReview(@RequestParam(value = "uName") String username,
            @RequestParam(value = "mName") String museumName,
            @RequestParam(value = "score") int score,
            @RequestParam(value = "comment") String comment) {
        boolean update = ReviewDAO.addReview(username, museumName, LocalDateTime.now().toString(), score, comment);
        MuseuDAO.updateScore(museumName);
        return update;
    }

    // ADMIN

    /**
     * Login admin - check credentials.
     *
     * @param adminName Username of the admin.
     * @param passwd    Password of the admin.
     * @return True if the login was successfull, false otherwise.
     */
    @GetMapping("/loginAdmin")
    public boolean loginAdmin(@RequestParam(value = "aName") String adminName,
            @RequestParam(value = "pw") String passwd) {
        return UtilizadorDAO.loginadmin(adminName, passwd);
    }

    /**
     * Receive all the museum information, create instance of the class museum and
     * insert into database.
     *
     * @param museumName Name of the museum.
     * @param price      Price of the museum.
     * @param location   Location of the museum (address).
     * @param website    Website of the museum.
     * @param contact    Contact of the museum (phone number, email, ...).
     * @param category   Category of the museum (art, science, ...).
     * @param images     Images of the museum - first image is the main one.
     * @return True if the museum was created, false otherwise.
     */
    @GetMapping("/newMuseum")
    public boolean createMuseum(@RequestParam(value = "mName") String museumName,
            @RequestParam(value = "price") int price,
            @RequestParam(value = "location") String location,
            @RequestParam(value = "web") String website,
            @RequestParam(value = "contact") String contact,
            @RequestParam(value = "category") String category,
            @RequestParam(value = "lat") Double latitude,
            @RequestParam(value = "lon") Double longitude,
            @RequestParam(value = "pics") List<String> images) {

        return MuseuDAO.addMuseum(museumName, price, location, website, contact, category,latitude,longitude,images);
    }

    /**
     * Remove the museum with the given name.
     *
     * @param museumName Museum name.
     * @return True if museum was removed, false otherwise.
     */
    @GetMapping("/removeMuseum")
    public boolean removeMuseum(@RequestParam(value = "mName") String museumName) {
        return MuseuDAO.removeMuseum(museumName);
    }

    /**
     * Edit a museum - remove and add.
     *
     * @param oldMuseumName Old museum name.
     * @param newMuseumName New name of the museum.
     * @param price      Price of the museum.
     * @param location   Location of the museum (address).
     * @param website    Website of the museum.
     * @param contact    Contact of the museum (phone number, email, ...).
     * @param category   Category of the museum (art, science, ...).
     * @param latitude   Latitude of the museum.
     * @param longitude  Longitude of the museum.
     * @param images     Images of the museum - first image is the main one.
     * @return True if the museum was created, false otherwise.
     */
    @GetMapping("/editMuseum")
    public boolean editMuseum(@RequestParam(value = "oldName") String oldMuseumName,
            @RequestParam(value = "newName") String newMuseumName,
            @RequestParam(value = "price") int price,
            @RequestParam(value = "location") String location,
            @RequestParam(value = "web") String website,
            @RequestParam(value = "contact") String contact,
            @RequestParam(value = "category") String category,
            @RequestParam(value = "lat") Double latitude,
            @RequestParam(value = "lon") Double longitude,
            @RequestParam(value = "pics") List<String> images)
    {
        return (this.removeMuseum(oldMuseumName)) &&
                this.createMuseum(newMuseumName, price, location, website, contact, category,latitude,longitude, images);
    }

    /**
     * 
     * @param username User name of the user.
     * @return History of a given user.
     */
    @GetMapping("/getHistory")
    public List<Regist> getHistory(@RequestParam(value = "uName") String username) {
        return makeHistory(Objects.requireNonNull(HistoryDAO.getHistory(username)));
    }

    /**
     * 
     * @return List with all program themes
     */
    @GetMapping("/getThemes")
    public List<String> getThemes() {
        return CategoryDAO.getCategorias();
    }

    /**
     * 
     * @param museumName Museum name of the museum.
     * @return List with all reviews about a given museum.
     */
    private List<Review> makeReviews(String museumName) {
        List<Review> reviews = new ArrayList<>();
        List<String> reviewInfo = ReviewDAO.getReviews(museumName);
        if (reviewInfo != null) {
            for (String review : reviewInfo) {
                reviews.add(new Review(review));
            }
            return reviews;
        }
        return null;
    }

    /**
     * .
     * 
     * @param museumsInfo List of museums Info.
     * @return List of museums.
     */
    private List<Museum> makeMuseums(List<String> museumsInfo) {
        List<Museum> museums = new ArrayList<>();
        for (String museumInfo : museumsInfo) {
            String[] splitInfo = museumInfo.split(";");
            museums.add(new Museum(museumInfo, MuseuDAO.getImages(splitInfo[0]), makeReviews(splitInfo[0]),
                    CategoryDAO.getCategoria(splitInfo[0])));
        }
        return museums;
    }

    /**
     * 
     * @param historyInfo History info from a user.
     * @return List with all regist from user history.
     */
    private List<Regist> makeHistory(List<String> historyInfo) {
        List<Regist> history = new ArrayList<>();
        for (String registInfo : historyInfo) {
            String[] splitInfo = registInfo.split(";");

            history.add(new Regist(splitInfo, getMuseumByName(splitInfo[0])));
        }

        return history;
    }
}
