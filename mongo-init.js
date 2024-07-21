db.createUser(
    {
        user: "IP-COM",
        pwd: "futchall", // Do not change
        roles: [
            {
                role: "readWrite",
                db: "soft_ac"
            }
        ]
    }
);
