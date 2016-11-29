/* Ce contrat est une version raffinée de MetacoinNAIF
 Il s'inspire notamment du contrat Coin consultable ici
http://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html
*/

/* Pour cette version nous allons notamment:
- restreindre les droits d'émission de la monnaie à une seule personne
- créer des événéments afin que des personnes extérieures puissent suivre
les modificiations du contrat
- ajouter un peu de flexibilité*/
pragma solidity ^0.4.6;

contract metaCoinv2 {
    
    address public minter;
    /* le droit d'émission de la monnaie revient au "minter", il est identifié
    par son addresse et cette adresse est publique */
    
    mapping (address => uint) public balances;

    /* Comme précédemment on définit un mapping avec les adresses et les soldes
    */
    
    event Sent(address from, address to, uint amount);
    event Create(address from, address to, uint amount);
    /*On définit les events "Sent" et "Create". L'Event est un type de fonction
     prenant jusqu'à 3 paramêtres en entrée et qui permet un usage pratique du 
     journal de la machine virtuelle d'ethereum. Lorsqu'un event est appelé il
    entraîne le stockage des arguments qu'il contient dans le journal des 
    transactions Les events permettent donc de suivre ce qui se passe dans le
    contrat depuis l'extérieure 
         */


modifier minterOnly {
        if (msg.sender != minter)
            throw;
        _;
    }
    /* le "modifier" permet de poser des conditions à l'exécution de certaines
    fonctions. Ici, "minterOnly" sera ajouté à la syntaxe des fonctions que l'on
    veut réserver au "minter". Le modifier teste la condion msg.sender != minter
    si le requêteur de la fonction n'est pas le minter alors l'exécution
    s'interrompt, c'est le sens du "throw". S'il s'agit bien du minter alors
    la fonction s'exécute. Notez le "_" underscore après le teste, il signifie
    à la fonction de continuer son exécution.*/
     
    function metaCoinv2() {
        minter = msg.sender;
    }
    /* Cette fonction est un "constructor" elle ne reçoit rien en argument et
    elle ne s'exécute qu'une seule fois à la création du contrat. En l'espèce
    la variable "minter" reçoit l'adresse "msg.sender" c'est à dire l'adresse
    de celui qui a déployé le contrat
    En l'absence de fonction spécifique pour modifier cette variable elle est
     immuable*/


    function changeMinter (address _newMinter)
       minterOnly
   {
       minter = _newMinter;
   }
   /* Cette fonction répond au problème du changement de Minter, l'ancien peut
   déléguer sa fonction à l'adresse (donc à la personne) de son choix. Le
   modifier minterOnly assure que lui seule puisse déléguer.*/

  
    function createCoin(address receiver, uint amount) minterOnly {
        balances[receiver] += amount;
        Create(msg.sender, receiver, amount);
    }

    /* par la fonction createCoin, le minter et seulement lui attribue un 
    montant "amount" à une adresse dans la mapping "balances". Notez que ce 
    montant ne pas peut être négatif. Cette opération est publiée dans le journal
    (le log) des transaction par l'event "Create" qui indique à tout le monde 
    que msg.sender (ie le minter) a attribué un montant a l'adresse receiver.*/   

    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }

    /* La fonction send peut être appelé par tout le monde. Le test initial est
    strict pour gérer les adresses qui ne sont pas sur le mapping (0 en solde).
    Cette opération est publiée dans le journal des transaction par l'event 
    "Sent" qui indique à tout le monde que msg.sender (ie le minter) a attribué 
    un montant a l'adresse receiver.*/

function kill() minterOnly { 
  selfdestruct(minter); }
       }
/* Cette dernière fonction permet de "nettoyer" la blockchain en supprimant le 
contrat. Il est important de la faire figurer pour libérer de l'espace sur 
la blockchain mais aussi pour supprimer un contrat buggé. En précisant une
adresse selfdestruct(address), tous les ethers stockés par le contrat y sont
envoyés. Attention si une transaction envoie des ethers à un contrat qui s'est
"selfdestruct" ces ethers seront perdus*/
