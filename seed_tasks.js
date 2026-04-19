// Seed agricultural tasks for producteurs
const db = db.getSiblingDB('agrismart');

const today = new Date();

// Get Monday of current week
const dayOfWeek = today.getDay();
const diff = today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1);
const monday = new Date(today.getFullYear(), today.getMonth(), diff);

// Create a dummy planId (MongoDB ObjectId constructor)
const dummyPlanId = ObjectId();

const tasks = [
  // Lundi - 4 tâches complétées
  {
    title: 'Performance parcelle (4 jours)',
    description: 'Qualité opérationnelle des tâches agricoles',
    taskType: 'semis',
    priority: 'high',
    status: 'done',
    dueDate: new Date(monday),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Parcelle A1 - Suivi et optimisation',
    createdAt: new Date(Date.now() - 10*24*60*60*1000),
    completedAt: new Date(Date.now() - 9*24*60*60*1000)
  },
  {
    title: 'Inspection du système d\'irrigation',
    description: 'Vérifier les goutteurs et les tuyaux',
    taskType: 'irrigation',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(monday),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Parcelle B2 - Maintenance préventive',
    createdAt: new Date(Date.now() - 8*24*60*60*1000),
    completedAt: new Date(Date.now() - 7*24*60*60*1000)
  },
  {
    title: 'Traitement fongicide',
    description: 'Application du traitement contre le mildiou',
    taskType: 'traitement',
    priority: 'high',
    status: 'done',
    dueDate: new Date(monday),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Parcelle C3 - Protection culturale',
    createdAt: new Date(Date.now() - 7*24*60*60*1000),
    completedAt: new Date(Date.now() - 6*24*60*60*1000)
  },
  {
    title: 'Préparation des planches de semis',
    description: 'Labourage et enrichissement du sol',
    taskType: 'semis',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(monday),
    planId: dummyPlanId,
    ownerEmail: 'producteur3@agrismart.com',
    notes: 'Parcelle D4 - Mise en place des cultures',
    createdAt: new Date(Date.now() - 6*24*60*60*1000),
    completedAt: new Date(Date.now() - 5*24*60*60*1000)
  },

  // Mardi - 5 tâches complétées
  {
    title: 'Désherbage manuel',
    description: 'Éradication des mauvaises herbes',
    taskType: 'autre',
    priority: 'low',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 1*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Parcelle A1 - Nettoyage régulier',
    createdAt: new Date(Date.now() - 5*24*60*60*1000),
    completedAt: new Date(Date.now() - 4*24*60*60*1000)
  },
  {
    title: 'Apport d\'engrais organique',
    description: 'Distribution du compost sur les planches',
    taskType: 'autre',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 1*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Parcelle E5 - Fertilisation naturelle',
    createdAt: new Date(Date.now() - 4*24*60*60*1000),
    completedAt: new Date(Date.now() - 3*24*60*60*1000)
  },
  {
    title: 'Contrôle des ravageurs',
    description: 'Inspection et pièges à insectes',
    taskType: 'traitement',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 1*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur3@agrismart.com',
    notes: 'Parcelle F6 - Lutte intégrée',
    createdAt: new Date(Date.now() - 3*24*60*60*1000),
    completedAt: new Date(Date.now() - 2*24*60*60*1000)
  },
  {
    title: 'Arrosage des cultures jeunes',
    description: 'Irrigation localisée pour les semis',
    taskType: 'irrigation',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 1*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Parcelle G7 - Développement des plants',
    createdAt: new Date(Date.now() - 2*24*60*60*1000),
    completedAt: new Date(Date.now() - 1*24*60*60*1000)
  },
  {
    title: 'Récolte des tomates mûres',
    description: 'Cueillette et tri en surface',
    taskType: 'recolte',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 1*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur4@agrismart.com',
    notes: 'Parcelle H8 - Récolte sélective',
    createdAt: new Date(Date.now() - 1*24*60*60*1000),
    completedAt: new Date()
  },

  // Mercredi - 7 tâches complétées
  {
    title: 'Nettoyage des outils',
    description: 'Désinfection après utilisation',
    taskType: 'autre',
    priority: 'low',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Stockage sécurisé',
    createdAt: new Date(Date.now() - 2*24*60*60*1000),
    completedAt: new Date()
  },
  {
    title: 'Inspection du drainage',
    description: 'Vérifier les fossés de drainage',
    taskType: 'irrigation',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Prévention de l\'engorgement',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Traitement anti-maladie',
    description: 'Application préventive de fongicide',
    taskType: 'traitement',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur3@agrismart.com',
    notes: 'Protection des pieds sensibles',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Semis des poireaux',
    description: 'Mise en terre des plants repiqués',
    taskType: 'semis',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Espacement de 15cm',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Élagage des branches mortes',
    description: 'Nettoyage des arbustes fruitiers',
    taskType: 'autre',
    priority: 'low',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur4@agrismart.com',
    notes: 'Favoriser la circulation d\'air',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Apport d\'eau pour arrosage',
    description: 'Remplissage des réservoirs',
    taskType: 'irrigation',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Préparation pour la semaine',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Récolte des courgettes',
    description: 'Cueillette à l\'état jeune',
    taskType: 'recolte',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 2*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur3@agrismart.com',
    notes: 'Meilleur goût et texture',
    createdAt: new Date(),
    completedAt: new Date()
  },

  // Jeudi - 6 tâches complétées
  {
    title: 'Paillage des cultures',
    description: 'Application de paille pour conservation humidité',
    taskType: 'autre',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Épaisseur 5-10cm',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Inspection phytosanitaire',
    description: 'Contrôle général des cultures',
    taskType: 'traitement',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Détection précoce des symptômes',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Montage des tuteurs',
    description: 'Installation des supports pour tomates',
    taskType: 'semis',
    priority: 'medium',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur3@agrismart.com',
    notes: 'Hauteur 1,8m - Bambou ou bois',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Arrosage profond',
    description: 'Infiltration de l\'eau en profondeur',
    taskType: 'irrigation',
    priority: 'high',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur4@agrismart.com',
    notes: 'Favorise l\'enracinement profond',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Récolte des épinards',
    description: 'Cueillette des feuilles tendres',
    taskType: 'recolte',
    priority: 'low',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur1@agrismart.com',
    notes: 'Avant montaison',
    createdAt: new Date(),
    completedAt: new Date()
  },
  {
    title: 'Récupération des semences',
    description: 'Collecte des graines mûres',
    taskType: 'autre',
    priority: 'low',
    status: 'done',
    dueDate: new Date(new Date(monday).getTime() + 3*24*60*60*1000),
    planId: dummyPlanId,
    ownerEmail: 'producteur2@agrismart.com',
    notes: 'Conservation pour l\'année prochaine',
    createdAt: new Date(),
    completedAt: new Date()
  }
];

// Insert all tasks
let count = 0;
tasks.forEach((task) => {
  db.tasks.insertOne(task);
  count++;
});

print(`✅ ${count} tasks seeded successfully!`);
print(`
Task Distribution:
  ✓ Lundi (Monday): 4 tâches complétées
  ✓ Mardi (Tuesday): 5 tâches complétées
  ✓ Mercredi (Wednesday): 7 tâches complétées
  ✓ Jeudi (Thursday): 6 tâches complétées
  
Total: ${count} agricultural tasks
`);
