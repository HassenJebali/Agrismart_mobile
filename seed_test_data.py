import pymongo
from bson import ObjectId
import datetime

def seed():
    client = pymongo.MongoClient('mongodb://localhost:27017')
    db = client['agrismart']
    
    user_id = '69e34ac6919aaf6be5966e20'
    email = 'testeur@agrismart.gn'
    
    # 1. Clean existing plots for this user to avoid mess
    db['plots'].delete_many({'ownerUserId': user_id})
    db['plots'].delete_many({'ownerUserId': email}) # Case where email was used
    
    plots = [
        {
            'ownerUserId': user_id,
            'name': 'Verger de Mornag',
            'status': 'healthy',
            'sizeHa': 2.5,
            'colorHex': '#2E7D32',
            'boundary': [
                {'lat': 36.678, 'lng': 10.288},
                {'lat': 36.680, 'lng': 10.289},
                {'lat': 36.679, 'lng': 10.291},
                {'lat': 36.677, 'lng': 10.290}
            ],
            'sensors': [
                {
                    'id': str(ObjectId()),
                    'name': 'Humidité Sol A1',
                    'type': 'soil_moisture',
                    'status': 'online',
                    'unit': '%',
                    'lastValue': 65.4,
                    'lastReadingAt': datetime.datetime.now(),
                    'position': {'lat': 36.6785, 'lng': 10.289}
                },
                {
                    'id': str(ObjectId()),
                    'name': 'Température Air T1',
                    'type': 'soil_temp',
                    'status': 'online',
                    'unit': '°C',
                    'lastValue': 24.2,
                    'lastReadingAt': datetime.datetime.now(),
                    'position': {'lat': 36.679, 'lng': 10.290}
                }
            ]
        },
        {
            'ownerUserId': user_id,
            'name': 'Champ de Blé - Sidi Thabet',
            'status': 'alert',
            'sizeHa': 5.2,
            'colorHex': '#FF9800',
            'boundary': [
                {'lat': 36.911, 'lng': 10.041},
                {'lat': 36.913, 'lng': 10.042},
                {'lat': 36.912, 'lng': 10.044},
                {'lat': 36.910, 'lng': 10.043}
            ],
            'sensors': [
                {
                    'id': str(ObjectId()),
                    'name': 'Conductivité Sol E1',
                    'type': 'soil_ec',
                    'status': 'warning',
                    'unit': 'mS/cm',
                    'lastValue': 2.1,
                    'lastReadingAt': datetime.datetime.now(),
                    'position': {'lat': 36.9115, 'lng': 10.042}
                }
            ]
        },
        {
            'ownerUserId': user_id,
            'name': 'Serre de Monastir',
            'status': 'healthy',
            'sizeHa': 1.1,
            'colorHex': '#009688',
            'boundary': [
                {'lat': 35.765, 'lng': 10.812},
                {'lat': 35.767, 'lng': 10.813},
                {'lat': 35.766, 'lng': 10.815},
                {'lat': 35.764, 'lng': 10.814}
            ],
            'sensors': [
                {
                    'id': str(ObjectId()),
                    'name': 'Capteur Humidité S1',
                    'type': 'soil_moisture',
                    'status': 'online',
                    'unit': '%',
                    'lastValue': 80.0,
                    'lastReadingAt': datetime.datetime.now(),
                    'position': {'lat': 35.7655, 'lng': 10.813}
                },
                {
                    'id': str(ObjectId()),
                    'name': 'Contrôleur Pompe P1',
                    'type': 'pump',
                    'status': 'online',
                    'unit': 'statut',
                    'lastValue': 1.0,
                    'lastReadingAt': datetime.datetime.now(),
                    'position': {'lat': 35.766, 'lng': 10.814}
                }
            ]
        }
    ]
    
    db['plots'].insert_many(plots)
    print(f"Successfully seeded {len(plots)} plots for user {email}")
    client.close()

if __name__ == '__main__':
    seed()
