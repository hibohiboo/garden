import * as express from 'express';
import { firestore } from '../model/firestore';


const router = express.Router();

// Read All Item
router.get('/', async (req, res, next) => {
  try {
    firestore.collection('characters').doc(characterId)
    // const itemSnapshot = await firestore.collection('characters').get();
    // const items: { id: string; data: any; }[] = [];
    // itemSnapshot.forEach((doc: { id: string; data: () => any; }) => {
    //   items.push({
    //     id: doc.id,
    //     data: doc.data()
    //   });
    // });
    // res.json(items);
  } catch (e) {
    next(e);
  }
});

// Error Handling
router.use((req, res, next) => {
  res.status(404).json({
    error: 'Route Not Found'
  });
});



export default router;