// Update offers without region
const db = db.getSiblingDB('agrismart');

const updates = [
  { product: 'Tomates fraiches premium', region: 'Conakry' },
  { product: 'Pommes de terre calibre moyen', region: 'Mamou' },
  { product: 'MaIs grain sec', region: 'Faranah' },
  { product: 'Semences riz irrigue', region: 'Kindia' },
  { product: 'Engrais NPK 15-15-15', region: 'Labé' },
  { product: 'Oignons rouges locaux', region: 'Conakry' }
];

updates.forEach((update) => {
  db.offers.updateOne(
    { product: update.product },
    { $set: { region: update.region } }
  );
  print(`Updated: ${update.product} -> ${update.region}`);
});

print('\nAll regions updated successfully!');
