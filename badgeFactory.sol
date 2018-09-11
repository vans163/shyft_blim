pragma solidity ^0.4.19;


contract badgeFactory{

    struct Badge{
        string name;
        address owner;
        //permissions
        //address origOwner;
        //trustAnchor //address or string?
    }

    Badge[] public badges;

    mapping (address => uint) ownerBadgeCount;
    mapping (address => uint) ownerRarity;
    mapping (address => uint) ownerPermissions; 

    function mintBadge(string _name, address _owner) internal{
        uint count = 0;
        for (uint i = 0; i < badges.length; i++) {
            if badges[i]
        }
        
        badges.push(Badge(name, rarity));

    }
    function getStats(address _owner){
        uint numBadge = 0;

        uint easyCount = 0;
        uint easyFlag = 0;

        uint hardCount = 0;
        uint hardFlag = 0;

        uint ehardCount = 0;
        uint ehardFlag = 0;

        for (uint i = 0; i < badges.length; i++) {
            if (badges[i].owner == owner) {
                numBadge ++;
                if (badges[i].name == "EASY") {
                    easyFlag == 1;
                }
                else if (badges[i].name == "HARD") {
                    hardFlag == 1;
                }
                else if (badges[i].name == "EHARD") {
                    ehardFlag == 1;
                }
            }

            if (badges[i].name == "EASY") {
                easyCount ++;
            }
            else if (badges[i].name == "HARD") {
                hardCount ++;
            }
            else if (badges[i].name == "EHARD") {
                ehardCount ++;
            }
        }

    }
}


    





